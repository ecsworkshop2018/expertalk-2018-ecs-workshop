terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket         = "ecs-workshop-terraform-state-jenkins"
    key            = "acm-certificate.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "Terraform-Lock-Table"
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "= 1.43.0"
}

resource "aws_acm_certificate" "ecs_workshop_certificate" {
  domain_name       = "*.ecsworkshop2018.online"
  validation_method = "DNS"
}

data "aws_route53_zone" "ecs_workshop_hosted_zone" {
  name         = "ecsworkshop2018.online."
  private_zone = false
}

module "cert_validation" {
  source                = "../../terraform-modules/route53-generic"
  hosted_zone           = "${data.aws_route53_zone.ecs_workshop_hosted_zone.name}"
  dns_record_set_name   = "${aws_acm_certificate.ecs_workshop_certificate.domain_validation_options.0.resource_record_name}"
  resource_record       = "${aws_acm_certificate.ecs_workshop_certificate.domain_validation_options.0.resource_record_value}"
  type                  = "${aws_acm_certificate.ecs_workshop_certificate.domain_validation_options.0.resource_record_type}"
  record_set_stack_name = "ecs-workshop-wildcard-certificate-cname-stack"
}

resource "aws_acm_certificate_validation" "ecs_workshop_certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.ecs_workshop_certificate.arn}"
  validation_record_fqdns = ["${module.cert_validation.fqdn}"]
}
