data "aws_guardduty_detector" "aws_guardduty_detector" {}

resource "aws_guardduty_organization_configuration" "aws_guardduty_organization_configuration" {
  detector_id                      = data.aws_guardduty_detector.aws_guardduty_detector.id
  auto_enable_organization_members = "ALL"
}

resource "aws_guardduty_detector_feature" "aws_guardduty_detector_feature" {
  for_each = toset([
    "S3_DATA_EVENTS",
    "EKS_AUDIT_LOGS",
    "EBS_MALWARE_PROTECTION",
    "RDS_LOGIN_EVENTS",
    "LAMBDA_NETWORK_LOGS"
  ])

  detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
  name        = each.value
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

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