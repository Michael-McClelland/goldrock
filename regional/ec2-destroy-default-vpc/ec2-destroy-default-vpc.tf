resource "awsutils_default_vpc_deletion" "default" {}

terraform {
  required_providers {
    awsutils = {
      source = "cloudposse/awsutils"
    }
  }
}

terraform {
  backend "s3" {
  }
}
