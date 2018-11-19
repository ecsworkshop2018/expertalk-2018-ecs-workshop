output "fqdn" {
  value = "${aws_cloudformation_stack.record-set.outputs["FQDN"]}"
}
