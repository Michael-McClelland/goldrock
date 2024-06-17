resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_delivery_channel" "config" {
  name           = "goldrock"
  s3_bucket_name = var.configservice_bucket_name
  s3_key_prefix  = data.aws_organizations_organization.current.id
  s3_kms_key_arn = "arn:aws:kms:us-east-2:543343844423:key/mrk-6e6d15e8b1b14ecb9070cddbdbe750ae"
}

resource "aws_config_configuration_recorder" "config" {
  name     = "goldrock"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }
}

resource "aws_config_retention_configuration" "example" {
  retention_period_in_days = 365
}

data "aws_organizations_organization" "current" {}

variable "configservice_bucket_name" {
  type = string
  default = "goldrock-configservice-543343844423-us-east-2"
}

# terraform {
#   backend "s3" {
#   }
# }