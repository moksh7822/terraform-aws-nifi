terraform {
  required_version = "~> 0.13.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }
}

# provider block

provider "aws" {
  profile = "default"
  region  = var.aws_region
}
