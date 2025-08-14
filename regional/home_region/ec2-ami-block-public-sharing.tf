resource "aws_ec2_image_block_public_access" "image_block_public_access" {
  state = "block-new-sharing"
}

resource "aws_ebs_snapshot_block_public_access" "aws_ebs_snapshot_block_public_access" {
  state = "block-all-sharing"
}