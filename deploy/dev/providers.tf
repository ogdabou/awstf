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
#
#    docker = {
#      source  = "kreuzwerker/docker"
#      version = "3.0.2"
#    }
  }
}

provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::654654272742:role/infra"
  }
}
#
#provider "docker" {
#  registry_auth {
#    address = ""
#    password = ""
#
#  }
#}