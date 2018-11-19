data "aws_route53_zone" "hosted_zone" {
  name         = "${var.hosted_zone}"
  private_zone = false
}

resource "aws_cloudformation_stack" "application-dns" {
  name          = "${var.app_name}-dns-${var.env}"
  template_body = "${file("${path.module}/dns_name.yaml")}"

  parameters {
    HostedZoneId             = "${data.aws_route53_zone.hosted_zone.id}"
    DNSName                  = "${var.dns_record_set_name}"
    LoadBalancerHostedZoneId = "${var.lb_zone_id}"
    LoadBalancerDNSName      = "dualstack.${var.lb_dns_name}"
    Environment              = "${var.env}"
    AppName                  = "${var.app_name}"
    Weight                   = "${var.weight}"
  }
}
