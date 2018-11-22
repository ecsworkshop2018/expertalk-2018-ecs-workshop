data "template_file" "user_data_ecs_cluster_part" {
  template = "${file("${path.module}/user_data_ecs_cluster_part.tpl")}"

  vars {
    cluster_name = "${aws_ecs_cluster.jenkins_cluster.name}"
  }
}

resource "aws_launch_configuration" "jenkins_lc" {
  name_prefix          = "${local.unique}-jenkins-lc"
  image_id             = "ami-07eb698ce660402d2"                                     // ECS AMI
  instance_type        = "t3.small"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_instance_profile.name}"

  security_groups = ["${aws_security_group.jenkins_ec2_sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              ${data.template_file.user_data_ecs_cluster_part.rendered}
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

resource "aws_security_group" "jenkins_ec2_sg" {
  name        = "${local.unique}-jenkins-ecs-sg"
  description = "jenkins cluster instances security group"
  vpc_id      = "${data.aws_vpc.dev_vpc.id}"

  tags {
    Name = "${local.unique}-jenkins-ecs-sg"
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