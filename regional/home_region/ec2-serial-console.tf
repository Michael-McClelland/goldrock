resource "aws_ec2_serial_console_access" "console" {
  enabled = false
}
terraform {
  backend "s3" {
  }
}
