resource "aws_ssm_service_setting" "public-sharing-permission" {
  setting_id    = "arn:${data.aws_partition.current.id}:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:servicesetting/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}

