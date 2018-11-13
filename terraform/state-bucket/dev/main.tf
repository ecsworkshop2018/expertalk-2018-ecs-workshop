terraform {
  required_version = "= 0.11.10"
}

provider "aws" {
  region  = "us-east-1"
  profile = "ecs-workshop"
  version = "= 1.43.0"
}

resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "ecs-workshop-terraform-state-dev"
  acl    = "private"
  region = "us-east-1"

  tags {
    Name        = "ecs-workshop-terraform-state-dev"
    Environment = "dev"
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform-lock-table" {

  "attribute" {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"
  name = "Terraform-Lock-Table"
  read_capacity = 5
  write_capacity = 5
}