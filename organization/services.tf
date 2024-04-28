resource "aws_guardduty_organization_admin_account" "aws_guardduty_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}

resource "aws_securityhub_organization_admin_account" "aws_securityhub_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}

resource "aws_detective_organization_admin_account" "aws_detective_organization_admin_account" {
  account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}

resource "aws_macie2_organization_admin_account" "aws_macie2_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
}