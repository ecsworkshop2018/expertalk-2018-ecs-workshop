data "aws_route53_zone" "hosted_zone" {
  name         = "${var.hosted_zone}"
  private_zone = false
}

resource "aws_cloudformation_stack" "record-set" {
  name          = "${var.record_set_stack_name}"
  template_body = "${file("${path.module}/dns_name.yaml")}"

  parameters {
    HostedZoneId   = "${data.aws_route53_zone.hosted_zone.id}"
    DNSName        = "${var.dns_record_set_name}"
    ResourceRecord = "${var.resource_record}"
    Type           = "${var.type}"
  }
}
