data "aws_guardduty_detector" "aws_guardduty_detector" {}

resource "aws_guardduty_organization_configuration" "aws_guardduty_organization_configuration" {
  detector_id                      = data.aws_guardduty_detector.aws_guardduty_detector.id
  auto_enable_organization_members = "ALL"

}

resource "aws_guardduty_organization_configuration_feature" "aws_guardduty_organization_configuration_feature" {
  for_each = toset([
    "EBS_MALWARE_PROTECTION",
    "EKS_AUDIT_LOGS",
    "LAMBDA_NETWORK_LOGS",
    "RDS_LOGIN_EVENTS",
    "S3_DATA_EVENTS"
  ])

  detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
  name        = each.value
  auto_enable = "ALL"
}

resource "aws_guardduty_organization_configuration_feature" "aws_guardduty_organization_configuration_feature_runtime_monitoring" {
  detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
  name        = "RUNTIME_MONITORING"
  auto_enable = "ALL"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }

  additional_configuration {
    name   = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = "ENABLED"
  }

  additional_configuration {
    name   = "EC2_AGENT_MANAGEMENT"
    status = "ENABLED"
  }
}
