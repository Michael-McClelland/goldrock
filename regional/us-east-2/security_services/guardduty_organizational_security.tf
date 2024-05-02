data "aws_guardduty_detector" "aws_guardduty_detector" {}

resource "aws_guardduty_organization_configuration" "aws_guardduty_organization_configuration" {
  auto_enable_organization_members = "ALL"

  detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id

  # datasources {
  #   s3_logs {
  #     auto_enable = true
  #   }
  #   kubernetes {
  #     audit_logs {
  #       enable = true
  #     }
  #   }
  #   malware_protection {
  #     scan_ec2_instance_with_findings {
  #       ebs_volumes {
  #         auto_enable = true
  #       }
  #     }
  #   }
  # }
}

# resource "aws_guardduty_organization_configuration_feature" "s3_data_events" {
#   detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
#   name        = "S3_DATA_EVENTS"
#   auto_enable = "ALL"
# }

# resource "aws_guardduty_organization_configuration_feature" "eks_audit_logs" {
#   detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
#   name        = "EKS_AUDIT_LOGS"
#   auto_enable = "ALL"
# }

# resource "aws_guardduty_organization_configuration_feature" "ebs_malware_protection" {
#   detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
#   name        = "EBS_MALWARE_PROTECTION"
#   auto_enable = "ALL"
# }

# resource "aws_guardduty_organization_configuration_feature" "rds_login_events" {
#   detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
#   name        = "RDS_LOGIN_EVENTS"
#   auto_enable = "ALL"
# }

# resource "aws_guardduty_organization_configuration_feature" "lambda_network_logs" {
#   detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
#   name        = "LAMBDA_NETWORK_LOGS"
#   auto_enable = "ALL"
# }

# resource "aws_guardduty_organization_configuration_feature" "runtime_monitoring" {
#   detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
#   name        = "RUNTIME_MONITORING"
#   auto_enable = "ALL"

#   additional_configuration {
#     name        = "EC2_AGENT_MANAGEMENT"
#     auto_enable = "ALL"
#   }
# }

# resource "aws_guardduty_organization_configuration_feature" "eks_runtime_monitoring" {
#   detector_id = data.aws_guardduty_detector.aws_guardduty_detector.id
#   name        = "EKS_RUNTIME_MONITORING"
#   auto_enable = "ALL"

#   additional_configuration {
#     name        = "EKS_ADDON_MANAGEMENT"
#     auto_enable = "ALL"
#   }
# }
