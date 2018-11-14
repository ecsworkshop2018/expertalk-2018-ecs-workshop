locals  {
  efs_volume_name = "efs-jenkins"
}

resource "aws_efs_file_system" "efs_jenkins_file_system" {
  creation_token = "${local.efs_volume_name}"
  tags {
    Name = "${local.efs_volume_name}"
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

data "aws_subnet_ids" "dev_vpc_private_subnet_ids" {
  vpc_id = "${data.aws_vpc.dev_vpc.id}"

  tags {
    Type = "private"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = "${length(data.aws_subnet_ids.dev_vpc_private_subnet_ids.ids)}"
  file_system_id  = "${aws_efs_file_system.efs_jenkins_file_system.id}"
  subnet_id       = "${element(data.aws_subnet_ids.dev_vpc_private_subnet_ids.ids, count.index)}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}
