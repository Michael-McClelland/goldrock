locals {
  config_settings = yamldecode(file("${path.module}/config-settings.yaml"))
}

resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_delivery_channel" "config" {
  name           = aws_config_configuration_recorder.config.name
  s3_bucket_name = "goldrock-configservice-${data.aws_ssm_parameter.security_account_id.value}-${data.aws_region.current.id}"
  s3_key_prefix  = data.aws_organizations_organization.organization.id
}

resource "aws_config_configuration_recorder" "config" {
  name     = "goldrock"
  role_arn = data.aws_iam_role.configservice.arn

  recording_group {
    all_supported                 = local.config_settings.all_supported
    include_global_resource_types = false
  }

  recording_mode {
    recording_frequency = local.config_settings.recording_frequency
  }
}

resource "aws_config_retention_configuration" "config" {
  retention_period_in_days = local.config_settings.retention_period_days
}