resource "aws_efs_file_system" "efs_jenkins_file_system" {
  creation_token = "efs-jenkins"
  tags {
    Name = "efs-jenkins"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EFS"
  vpc_id      = "${data.aws_vpc.dev_vpc.id}"
  tags {
    Name = "efs-sg"
  }
}

resource "aws_security_group" "efs_client_sg" {
  name        = "efs-client-sg"
  description = "Security group for EFS Clients"
  vpc_id      = "${data.aws_vpc.dev_vpc.id}"
  tags {
    Name = "efs-client-sg"
  }
}

resource "aws_security_group_rule" "efs_sg_ingress_access" {
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.efs_sg.id}"
  to_port                  = 2049
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.efs_client_sg.id}"
}

resource "aws_security_group_rule" "efs_client_sg_allow_all_egress_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.efs_client_sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_subnet" "dev_vpc_private_subnets" {
  vpc_id = "${data.aws_vpc.dev_vpc.id}"
  count = "${length(data.aws_availability_zones.all.names)}"
  availability_zone="${element(data.aws_availability_zones.all.names, count.index)}"

  tags {
    Name = "dev-ecs-workshop-private-subnet-${count.index}"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = "${length(data.aws_subnet.dev_vpc_private_subnets.*.id)}"
  file_system_id  = "${aws_efs_file_system.efs_jenkins_file_system.id}"
  subnet_id       = "${element(data.aws_subnet.dev_vpc_private_subnets.*.id, count.index)}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}
