terraform {
  required_version = "= 0.11.10"
}

provider "aws" {
  region  = "us-east-1"
  profile = "ecs-workshop"
  version = "= 1.43.0"
}

resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "ecs-workshop-jenkins-terraform-state"
  acl    = "private"
  region = "us-east-1"

  tags {
    Name        = "ecs-workshop-jenkins-terraform-state"
    Environment = "jenkins"
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
