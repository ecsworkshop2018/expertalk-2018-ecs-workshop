terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    bucket  = "ecs-workshop-jenkins-terraform-state"
    key     = "jenkins.tfstate"
    region  = "ap-south-1"
    profile = "ecs-workshop"
    encrypt = true
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "ecs-workshop"
  version = "= 1.43.0"
}

data "aws_vpc" "dev_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dev-ecs-workshop-vpc"]
  }
}

data aws_availability_zones all {}

data "aws_subnet" "dev_vpc_public_subnets" {
  vpc_id            = "${data.aws_vpc.dev_vpc.id}"
  count             = "${length(data.aws_availability_zones.all.names)}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"

  filter {
    name   = "mapPublicIpOnLaunch"
    values = ["true"]
  }

  filter {
    name   = "tag:Environment"
    values = ["dev"]
  }
}

module "alb" {
  source                      = "../../terraform-modules/application-load-balancer"
  vpc_id                      = "${data.aws_vpc.dev_vpc.id}"
  name                        = "ecs-workshop-jenkins-alb"
  alb_access_cidr_blocks      = ["0.0.0.0/0"]
  alb_access_ipv6_cidr_blocks = ["::/0"]
  environment                 = "jenkins"
  public_subnet_ids           = ["${data.aws_subnet.dev_vpc_public_subnets.*.id}"]
}
