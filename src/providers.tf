terraform {

  backend "s3" {
    bucket = "awstf-infra"
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
  region = "us-east-1"
}
