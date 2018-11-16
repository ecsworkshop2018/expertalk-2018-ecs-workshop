terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket         = "ecs-workshop-terraform-state-jenkins"
    key            = "jenkins.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "Terraform-Lock-Table"
  }
}

provider "aws" {
  region  = "${local.region}"
  version = "= 1.43.0"
}

provider "template" {
  version = "= 1.0"
}

data "aws_vpc" "dev_vpc" {
  tags {
    Name = "dev-ecs-workshop"
  }
}

data "aws_subnet_ids" "dev_vpc_public_subnet_ids" {
  vpc_id = "${data.aws_vpc.dev_vpc.id}"

  tags {
    Type = "public"
  }
}

module "alb" {
  source                      = "../../terraform-modules/application-load-balancer"
  vpc_id                      = "${data.aws_vpc.dev_vpc.id}"
  name                        = "ecs-workshop-jenkins-alb"
  alb_access_cidr_blocks      = ["0.0.0.0/0"]
  alb_access_ipv6_cidr_blocks = ["::/0"]
  environment                 = "jenkins"
  public_subnet_ids           = ["${data.aws_subnet_ids.dev_vpc_public_subnet_ids.ids}"]
}

resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins_cluster"
}

resource "aws_key_pair" "jenkins_ssh_key" {
  key_name   = "jenkins-ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTF3Lf8VMPJ0SbM32IiE8qHRVL/WZd9uVMyI/KNWrm92k6jhmWtLpBgfbhHvuvITix2HxQ8rYqUmIMi480J0Y1x+/urXgcZJMDHNQU/pDzwsKSFpkYkqb0I0lqWymiEUbk34IMQeQ1mAbNHxSMFRy1/e3/nuWYKysVrvznu28L3jSJlI5SwGqoW/HswroupVuG02+ckRsgBrppIzWxz0eZNpwWZQoyvO3SPMdin0W9NeOb6gZLAxVLL13Wy0EnB4TMVPs2mB8gFDclkKti+i+uVh8hTTFWxGkMMataGIaGWvqqVXO1YrAhaLIsnlQ1hRnl4H16QpgfBKDzppABxr9R vagrant@ubuntu-xenial"
}

resource aws_launch_configuration "jenkins_lc" {
  image_id             = "ami-07eb698ce660402d2"                                     // ECS AMI
  instance_type        = "m3.medium"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_instance_profile.name}"

  security_groups = ["${aws_security_group.jenkins_ec2_sg.id}", "${aws_security_group.efs_client_sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              ${data.template_file.user_data_efs_mount_part.rendered}
              ${data.template_file.user_data_ecs_cluster_part.rendered}
              EOF

  lifecycle = {
    create_before_destroy = "true"
  }

  key_name = "${aws_key_pair.jenkins_ssh_key.key_name}"

  root_block_device {
    // Recommended for ECS AMI https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-storage-config.html
    volume_size           = "30"
    delete_on_termination = true
  }
}

resource aws_autoscaling_group "jenkins_asg" {
  name                      = "jenkins-asg"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.jenkins_lc.name}"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.dev_vpc_public_subnet_ids.ids}"]
  default_cooldown          = 300

  initial_lifecycle_hook {
    name                 = "asg-drain-before-terminate-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = "600"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"

    notification_metadata = <<EOF
    {
      "cluster-name": "${aws_ecs_cluster.jenkins_cluster.name}"
    }
    EOF

    //notification_target_arn = "${var.ecs_asg_drain_container_instances_lambda_events_queue}"
    //role_arn = "${aws_iam_role.ecs_asg_notification_access_role.arn}"
  }

  enabled_metrics = [
    "GroupStandbyInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
  ]

  tag {
    key                 = "Name"
    value               = "jenkins-ecs-asg-ec2"
    propagate_at_launch = true
  }

  tag {
    key                 = "Description"
    value               = "EC2 ASG for jenkins ECS cluster"
    propagate_at_launch = true
  }
}

data "template_file" "user_data_efs_mount_part" {
  template = "${file("${path.module}/user_data_efs_mount_part.tpl")}"

  vars {
    file_system_id = "${aws_efs_file_system.efs_jenkins_file_system.id}"
    efs_directory  = "${local.efs_host_path}"
    cluster_name   = "${aws_ecs_cluster.jenkins_cluster.name}"
  }
}

data "template_file" "user_data_ecs_cluster_part" {
  template = "${file("${path.module}/user_data_ecs_cluster_part.tpl")}"

  vars {
    cluster_name = "${aws_ecs_cluster.jenkins_cluster.name}"
  }
}

locals {
  efs_host_path = "/var/jenkins_home"
  region        = "us-east-1"
}

resource "aws_security_group" "jenkins_ec2_sg" {
  name        = "jenkins-ecs-sg"
  description = "jenkins cluster instances security group"
  vpc_id      = "${data.aws_vpc.dev_vpc.id}"

  tags {
    Name = "jenkins-ecs-sg"
  }
}

resource "aws_security_group_rule" "ec2_ingress_ephemeral_port_range_tcp_alb_access" {
  from_port                = 31000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.jenkins_ec2_sg.id}"
  to_port                  = 61000
  type                     = "ingress"
  source_security_group_id = "${module.alb.alb_sg_id}"
}

resource "aws_security_group_rule" "ec2_ingress_ssh_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_ec2_sg.id}"
  to_port           = 22
  type              = "ingress"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "ec2_egress_allow_all" {
  from_port         = 0
  protocol          = -1
  security_group_id = "${aws_security_group.jenkins_ec2_sg.id}"
  to_port           = 0
  type              = "egress"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
