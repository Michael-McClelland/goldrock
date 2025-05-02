terraform {
  required_version = ">= 1.8.4"
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