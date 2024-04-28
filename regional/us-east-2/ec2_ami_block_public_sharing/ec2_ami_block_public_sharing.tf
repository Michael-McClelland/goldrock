resource "aws_ec2_image_block_public_access" "image_block_public_access" {
  state = "block-new-sharing"
}
terraform {
  backend "s3" {
  }
}
