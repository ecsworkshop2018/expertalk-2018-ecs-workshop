terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket  = "prod-ecs-workshop-terraform-state"
    key     = "prod-vpc-subnets-and-network.tfstate"
    region  = "ap-south-1"
    profile = "ecs-workshop"
    encrypt = true
  }
}

locals {
  environment = "prod"
  region      = "ap-south-1"
}

provider "aws" {
  region  = "${local.region}"
  profile = "ecs-workshop"
  version = "= 1.43.0"
}

module "vpc" {
  source               = "../../../terraform-modules/vpc-subnets-and-network"
  name                 = "${local.environment}-ecs-workshop"
  environment          = "${local.environment}"
  vpc_cidr             = "172.30.0.0/20"
  public_subnet_cidrs  = ["172.30.0.0/22", "172.30.4.0/22"]
  private_subnet_cidrs = ["172.30.8.0/22", "172.30.12.0/22"]
  region               = "${local.region}"
}
