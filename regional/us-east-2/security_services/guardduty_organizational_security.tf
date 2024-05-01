data "aws_guardduty_detector" "aws_guardduty_detector" {}

resource "aws_guardduty_organization_configuration" "aws_guardduty_organization_configuration" {
  auto_enable_organization_members = "ALL"

  detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id

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
resource "aws_guardduty_organization_configuration_feature" "eks_runtime_monitoring" {
  detector_id = aws_guardduty_detector.aws_guardduty_detector.id
  name        = "EKS_RUNTIME_MONITORING"
  auto_enable = "ALL"

  additional_configuration {
    name        = "EKS_ADDON_MANAGEMENT"
    auto_enable = "NEW"
  }
}