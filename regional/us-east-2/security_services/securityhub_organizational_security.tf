resource "aws_securityhub_finding_aggregator" "aws_securityhub_finding_aggregator" {
  linking_mode = "ALL_REGIONS"
}

resource "aws_securityhub_organization_configuration" "aws_securityhub_organization_configuration" {
  auto_enable           = false
  auto_enable_standards = "NONE"
  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [aws_securityhub_finding_aggregator.aws_securityhub_finding_aggregator]
}