data "aws_guardduty_detector" "aws_guardduty_detector" {}

resource "aws_guardduty_organization_configuration" "aws_guardduty_organization_configuration" {
  detector_id                      = data.aws_guardduty_detector.aws_guardduty_detector.id
  auto_enable_organization_members = "ALL"

  datasources {
    s3_logs {
      auto_enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = true
        }
      }
    }
  }
}

resource "aws_guardduty_detector_feature" "aws_guardduty_detector_feature" {
  for_each = toset([
    "EBS_MALWARE_PROTECTION",
    "EKS_AUDIT_LOGS",
    "LAMBDA_NETWORK_LOGS",
    "RDS_LOGIN_EVENTS",
    "S3_DATA_EVENTS"
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