terraform {
  required_version = "= 0.11.10"
}

provider "aws" {
  region  = "us-east-1"
  version = "= 1.43.0"
}

resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "ecs-workshop-terraform-state-jenkins"
  acl    = "private"
  region = "us-east-1"

  tags {
    Name        = "ecs-workshop-terraform-state-jenkins"
    Environment = "jenkins"
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_repository" "ecs_workshop_jenkins" {
  name = "ecs-workshop/jenkins"
}
