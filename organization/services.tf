# resource "aws_guardduty_organization_admin_account" "aws_guardduty_organization_admin_account" {
#   admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
# }

resource "aws_securityhub_organization_admin_account" "aws_securityhub_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}

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

resource "aws_organizations_delegated_administrator" "guardduty" {
  account_id        = module.organization_structure.all_accounts.goldrock-securityservices.id
  service_principal = "guardduty.amazonaws.com"
}