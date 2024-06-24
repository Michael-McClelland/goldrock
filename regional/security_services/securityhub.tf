resource "aws_securityhub_finding_aggregator" "aws_securityhub_finding_aggregator" {
  linking_mode = "ALL_REGIONS"
}

resource "aws_securityhub_organization_configuration" "aws_securityhub_organization_configuration" {
  auto_enable           = false
  auto_enable_standards = "NONE"
  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [
    aws_securityhub_finding_aggregator.aws_securityhub_finding_aggregator
  ]
}

resource "aws_securityhub_configuration_policy" "aws_securityhub_configuration_policy" {
  name        = "default"
  description = "default"

  configuration_policy {
    service_enabled = true
    enabled_standard_arns = [
      "arn:${data.aws_partition.current.id}:securityhub:${data.aws_region.current.id}::standards/aws-foundational-security-best-practices/v/1.0.0",
      "arn:${data.aws_partition.current.id}:securityhub:${data.aws_region.current.id}::standards/cis-aws-foundations-benchmark/v/3.0.0",
    ]
    security_controls_configuration {
      disabled_control_identifiers = []
    }
  }

  depends_on = [aws_securityhub_organization_configuration.aws_securityhub_organization_configuration]
}

resource "aws_securityhub_configuration_policy_association" "root" {
  target_id = data.aws_organizations_organization.current.roots[0].id
  policy_id = aws_securityhub_configuration_policy.aws_securityhub_configuration_policy.id
}