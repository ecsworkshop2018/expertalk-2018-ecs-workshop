output "alb_sg_id" {
  value = "${aws_security_group.alb.id}"
}

output "alb_arn" {
  value = "${aws_alb.alb.arn}"
}

output "alb_https_listener_arn" {
  value = "${aws_alb_listener.alb_https_listener.arn}"
}

output "alb_https_listener_default_tg_arn" {
  value = "${aws_alb_target_group.alb_https_tg.arn}"
}

output "alb_dns_name" {
  value = "${aws_alb.alb.dns_name}"
}

output "alb_zone_id" {
  value = "${aws_alb.alb.zone_id}"
}
