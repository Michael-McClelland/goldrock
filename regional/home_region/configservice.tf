resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_delivery_channel" "config" {
  name           = aws_config_configuration_recorder.config.name
  s3_bucket_name = "goldrock-configservice-${var.security_account_id}-${data.aws_region.current.id}"
  s3_key_prefix  = data.aws_organizations_organization.current.id
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
data "aws_region" "current" {}

variable "security_account_id" {
  type = string
}