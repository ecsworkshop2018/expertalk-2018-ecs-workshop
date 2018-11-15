
resource "aws_alb_target_group" "alb_jenkins_target_group" {
  name                 = "${local.service_name}-tg"
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = "${data.aws_vpc.dev_vpc.id}"
  deregistration_delay = "30"

  health_check {
    protocol            = "HTTP"
    path                = "${local.jenkins_context_path}"
    matcher             = "200,302"
    interval            = "10"
    timeout             = "5"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener_rule" "service_listner_rule" {
  listener_arn = "${module.alb.alb_http_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_jenkins_target_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["${local.jenkins_context_path}"]
  }
}

resource "aws_alb_listener_rule" "service_listner_rule_star" {
  listener_arn = "${module.alb.alb_http_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_jenkins_target_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["${local.jenkins_context_path}/*"]
  }
}
