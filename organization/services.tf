resource "aws_guardduty_organization_admin_account" "aws_guardduty_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}

resource "aws_securityhub_organization_admin_account" "aws_securityhub_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id

  depends_on = [aws_securityhub_account.aws_securityhub_management_account]
}

#Workaround for SecurityHub Central Configuration
resource "aws_securityhub_account" "aws_securityhub_management_account" {
  auto_enable_controls = true
  control_finding_generator = "STANDARD_CONTROL"
  enable_default_standards = false
}

# import {
#   to = aws_securityhub_account.aws_securityhub_management_account
#   id = data.aws_caller_identity.caller.account_id
# }

resource "aws_detective_organization_admin_account" "aws_detective_organization_admin_account" {
  account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}

resource "aws_macie2_organization_admin_account" "aws_macie2_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}

resource "aws_organizations_delegated_administrator" "access_analyzer" {
  account_id        = module.organization_structure.all_accounts.goldrock-securityservices.id
  service_principal = "access-analyzer.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "cloudtrail" {
  account_id        = module.organization_structure.all_accounts.goldrock-securityservices.id
  service_principal = "cloudtrail.amazonaws.com"
}