terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region1
  alias  = "region1"
}

provider "aws" {
  region = var.region2
  alias  = "region2"
}