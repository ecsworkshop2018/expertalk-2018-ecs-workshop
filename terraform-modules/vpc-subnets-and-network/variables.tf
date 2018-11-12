variable "region" {}

variable "name" {}

variable "environment" {}

variable "vpc_cidr" {}

variable "public_subnet_cidrs" {
  type = "list"
}

variable "private_subnet_cidrs" {
  type = "list"
}

variable "destination_cidr_block" {
  description = "The CIDR block of the outbound route table routes"
  default     = "0.0.0.0/0"
}
