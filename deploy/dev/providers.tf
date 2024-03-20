terraform {
  backend "s3" {
    bucket = "awstf-infra-2"
    key    = "terraform/dev/state"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::654654272742:role/infra"
  }
}
