resource "aws_ec2_instance_metadata_defaults" "enforce-imdsv2" {
  http_endpoint               = "enabled"
  http_put_response_hop_limit = 1
  http_tokens                 = "required"
  instance_metadata_tags      = "disabled"
}
terraform {
  backend "s3" {
  }
}
