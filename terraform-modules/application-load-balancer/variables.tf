variable "vpc_id" {}

variable "name" {}

variable "environment" {}

variable "certificate_arn" {}

variable "health_check_path" {
  default = "/"
}
variable "health_check_allowed_codes" {
  default = "200"
}

variable "alb_access_cidr_blocks" {
  type = "list"
}

variable "alb_access_ipv6_cidr_blocks" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}
