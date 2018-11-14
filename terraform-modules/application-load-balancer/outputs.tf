output "alb_sg_id" {
  value = "${aws_security_group.alb.id}"
}

output "alb_arn" {
  value = "${aws_alb.alb.arn}"
}

output "alb_http_listener_arn" {
  value = "${aws_alb_listener.alb_http_listener.arn}"
}