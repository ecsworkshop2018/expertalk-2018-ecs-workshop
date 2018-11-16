resource "aws_security_group" "alb" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for ECS ALB in ${var.environment}"

  tags {
    Name        = "${var.name}-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "direct_access_to_https" {
  security_group_id = "${aws_security_group.alb.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.alb_access_cidr_blocks}"]
  ipv6_cidr_blocks  = ["${var.alb_access_ipv6_cidr_blocks}"]
}

resource "aws_security_group_rule" "alb_egress_to_any" {
  security_group_id = "${aws_security_group.alb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}
