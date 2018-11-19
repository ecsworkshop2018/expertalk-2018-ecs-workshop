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

  deregistration_delay = 60

  tags {
    Name        = "${var.name}-https-tg"
    Environment = "${var.environment}"
  }

  health_check {
    protocol            = "HTTP"
    path                = "${var.health_check_path}"
    matcher             = "${var.health_check_allowed_codes}"
    interval            = "10"
    timeout             = "5"
    healthy_threshold   = "3"
    unhealthy_threshold = "10"
  }
}

resource "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_https_tg.arn}"
    type             = "forward"
  }
}
