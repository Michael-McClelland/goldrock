provider "awsutils" {}

terraform {
  required_providers {
    awsutils = {
      source = "cloudposse/awsutils"
    }
  }
}