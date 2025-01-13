resource "aws_vpc_block_public_access_options" "aws_vpc_block_public_access_options" {
  internet_gateway_block_mode = "block-ingress"
}