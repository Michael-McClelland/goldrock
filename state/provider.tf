provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      version = ">= 5.33.0"
      source  = "hashicorp/aws"
    }
  }

}
