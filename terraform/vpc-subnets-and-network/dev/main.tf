terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket  = "dev-ecs-workshop-terraform-state"
    key     = "dev-vpc-subnets-and-network.tfstate"
    region  = "ap-south-1"
    profile = "ecs-workshop"
    encrypt = true
  }
}

locals {
  environment = "dev"
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
  vpc_cidr             = "172.29.0.0/20"
  public_subnet_cidrs  = ["172.29.0.0/22", "172.29.4.0/22"]
  private_subnet_cidrs = ["172.29.8.0/22", "172.29.12.0/22"]
  region               = "${local.region}"
}
