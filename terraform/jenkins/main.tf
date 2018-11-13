terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket  = "ecs-workshop-jenkins-terraform-state"
    key     = "jenkins.tfstate"
    region  = "us-east-1"
    profile = "ecs-workshop"
    encrypt = true
    lock_table = ""
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "ecs-workshop"
  version = "= 1.43.0"
}

data "aws_vpc" "dev_vpc" {
  tags {
    Name = "dev-ecs-workshop"
  }
}

data aws_availability_zones all {}

data "aws_subnet" "dev_vpc_public_subnets" {
  vpc_id            = "${data.aws_vpc.dev_vpc.id}"
  count             = "${length(data.aws_availability_zones.all.names)}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"

  tags {
    Name = "dev-ecs-workshop-public-subnet-${count.index}"
  }
}

module "alb" {
  source                      = "../../terraform-modules/application-load-balancer"
  vpc_id                      = "${data.aws_vpc.dev_vpc.id}"
  name                        = "ecs-workshop-jenkins-alb"
  alb_access_cidr_blocks      = ["0.0.0.0/0"]
  alb_access_ipv6_cidr_blocks = ["::/0"]
  environment                 = "jenkins"
  public_subnet_ids           = ["${data.aws_subnet.dev_vpc_public_subnets.*.id}"]
}

resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins_cluster"
}

resource aws_launch_configuration "jenkins_lc" {
  image_id = "ami-05f009513cd58ac90" // ECS AMI
  instance_type = "m3.medium"

  security_groups = []

  user_data = <<-EOF
			  cat <<'CONFIG' >> /etc/ecs/ecs.config
			  ECS_CLUSTER=${aws_ecs_cluster.jenkins_cluster.name}
			  ECS_ENABLE_TASK_IAM_ROLE=true
			  ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
			  CONFIG
			  EOF

  lifecycle = {
    create_before_destroy = "true"
  }

  root_block_device {
    // Recommended for ECS AMI https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-storage-config.html
    volume_size           = "30"
    delete_on_termination = true
  }
}

data "template_file" "user_data_efs_mount_part" {
  template = "${file("${path.module}/user_data_efs_mount_part.tpl")}"

  vars {
    file_system_id = "${aws_efs_file_system.efs_jenkins_file_system.id}"
    efs_directory  = "/var/jenkins_home"
    cluster_name   = "${aws_ecs_cluster.jenkins_cluster.name}"
  }
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