data aws_route53_zone "ecs_workshop_hosted_zone" {
  name = "ecsworkshop2018.online."
}

module "dns" {
  source              = "../../terraform-modules/route53-alias"
  weight              = "100"
  lb_dns_name         = "${module.alb.alb_dns_name}"
  lb_zone_id          = "${module.alb.alb_zone_id}"
  hosted_zone         = "${data.aws_route53_zone.ecs_workshop_hosted_zone.name}"
  dns_record_set_name = "jenkins.ecsworkshop2018.online"
  env                 = "dev"
  app_name            = "jenkins"
}

resource "aws_acm_certificate" "jenkins_certificate" {
  domain_name       = "jenkins.ecsworkshop2018.online"
  validation_method = "DNS"
}
