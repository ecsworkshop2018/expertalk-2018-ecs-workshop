resource "aws_alb" "alb" {
  name            = "${var.name}"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${var.public_subnet_ids}"]
  idle_timeout    = 450

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "alb_https_tg" {
  name     = "${var.name}-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  count    = "${var.certificate_arn == "" ? 0 : 1}"

  deregistration_delay = 60

  tags {
    Name        = "${var.name}-https-tg"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"
  count             = "${var.certificate_arn == "" ? 0 : 1}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_https_tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "alb_http_tg" {
  name     = "${var.name}-http-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  deregistration_delay = 60

  tags {
    Name        = "${var.name}-http-tg"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "alb_http_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_http_tg.arn}"
    type             = "forward"
  }
}
