terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      version = ">= 5.46.0"
      source  = "hashicorp/aws"
    }
  }

}
terraform {
  backend "s3" {
  }
}