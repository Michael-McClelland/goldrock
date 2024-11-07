resource "aws_ssm_service_setting" "test_setting" {
  setting_id    = "arn:${data.aws_partition.partition.id}:ssm:${data.aws_region.region.id}:${data.aws_caller_identity.caller.id}:servicesetting/ssm/documents/console/public-sharing-permission"
  setting_value = "Enable"
}

