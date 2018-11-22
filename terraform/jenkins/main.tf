terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket         = "ecs-workshop-terraform-state-jenkins"
    key            = "${unique}-jenkins.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "Terraform-Lock-Table"
  }
}

provider "aws" {
  region  = "${local.region}"
  version = "= 1.43.0"
}

provider "template" {
  version = "= 1.0"
}

provider "null" {
  version = "= 1.0"
}

data "aws_vpc" "dev_vpc" {
  tags {
    Name = "dev-ecs-workshop"
  }
}

data "aws_subnet_ids" "dev_vpc_public_subnet_ids" {
  vpc_id = "${data.aws_vpc.dev_vpc.id}"

  tags {
    Type = "public"
  }
}

variable "unique_identifier" {}

locals {
  unique = "${var.unique_identifier}"
  region = "us-east-1"
}

module "alb" {
  source                      = "../../terraform-modules/application-load-balancer"
  vpc_id                      = "${data.aws_vpc.dev_vpc.id}"
  name                        = "${local.unique}-jenkins-alb"
  alb_access_cidr_blocks      = ["0.0.0.0/0"]
  alb_access_ipv6_cidr_blocks = ["::/0"]
  environment                 = "jenkins"
  public_subnet_ids           = ["${data.aws_subnet_ids.dev_vpc_public_subnet_ids.ids}"]
  certificate_arn             = "${data.aws_acm_certificate.jenkins_certificate.arn}"
  health_check_allowed_codes  = "200,302"
  health_check_path           = "/whoAmI"
}

resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "${local.unique}-jenkins-cluster"
}


