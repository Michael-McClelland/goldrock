resource "aws_ram_sharing_with_organization" "aws_ram_sharing_with_organization" {}

resource "aws_ram_resource_share" "goldrock_parameters" {
  name                      = "goldrock-parameters"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "goldrock_parameters" {
  resource_arn       = aws_ssm_parameter.goldrock_security_account_id.arn
  resource_share_arn = aws_ram_resource_share.goldrock_parameters.arn
}

resource "aws_ram_principal_association" "goldrock_parameters" {
  principal          = aws_organizations_organization.organization.arn
  resource_share_arn = aws_ram_resource_share.goldrock_parameters.arn
}