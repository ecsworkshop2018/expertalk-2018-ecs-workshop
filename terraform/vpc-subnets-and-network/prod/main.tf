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
  source      = "../../../terraform-modules/vpc"
  name        = "ecs-workshop-vpc"
  environment = "${local.environment}"
  cidr        = "172.30.0.0/20"
  region      = "${local.region}"
}

module "public_subnet_1" {
  source         = "../../../terraform-modules/subnet"
  name           = "ecs-workshop-public-subnet-1"
  environment    = "${local.environment}"
  vpc_id         = "${module.vpc.vpc_id}"
  az             = "${local.region}a"
  is_public      = true
  cidr           = "172.30.0.0/22"
  route_table_id = "${module.vpc.main_route_table_id}"
}

module "public_subnet_2" {
  source         = "../../../terraform-modules/subnet"
  name           = "ecs-workshop-public-subnet-2"
  environment    = "${local.environment}"
  vpc_id         = "${module.vpc.vpc_id}"
  az             = "${local.region}b"
  is_public      = true
  cidr           = "172.30.4.0/22"
  route_table_id = "${module.vpc.main_route_table_id}"
}

module "routes" {
  source              = "../../../terraform-modules/routes"
  name                = "ecs-workshop"
  environment         = "${local.environment}"
  vpc_id              = "${module.vpc.vpc_id}"
  public_subnet_id    = "${module.public_subnet_1.subnet_id}"
  main_route_table_id = "${module.vpc.main_route_table_id}"
}

module "private_subnet_1" {
  source         = "../../../terraform-modules/subnet"
  name           = "ecs-workshop-private-subnet-1"
  environment    = "${local.environment}"
  vpc_id         = "${module.vpc.vpc_id}"
  az             = "${local.region}a"
  is_public      = false
  cidr           = "172.30.8.0/22"
  route_table_id = "${module.routes.private_route_table_id}"
}

module "private_subnet_2" {
  source         = "../../../terraform-modules/subnet"
  name           = "ecs-workshop-private-subnet-2"
  environment    = "${local.environment}"
  vpc_id         = "${module.vpc.vpc_id}"
  az             = "${local.region}b"
  is_public      = false
  cidr           = "172.30.12.0/22"
  route_table_id = "${module.routes.private_route_table_id}"
}
