resource "aws_default_vpc" "default" {
  force_destroy = true
}
terraform {
  backend "s3" {
  }
}