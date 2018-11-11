variable "vpc_id" {}

variable "name" {}

variable "environment" {}

variable "public_subnet_id" {}

variable "main_route_table_id" {}

variable "destination_cidr_block" {
  description = "The CIDR block of the outbound route table routes"
  default     = "0.0.0.0/0"
}
