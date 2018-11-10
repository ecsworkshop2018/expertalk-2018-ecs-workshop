terraform {
  required_version = "= 0.11.10"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "ecs-workshop"
  version = "= 1.43.0"
}

resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "prod-ecs-workshop-terraform-state"
  acl    = "private"
  region = "ap-south-1"

  tags {
    Name        = "prod-ecs-workshop-terraform-state"
    Environment = "prod"
  }

  lifecycle {
    prevent_destroy = false
  }
}
