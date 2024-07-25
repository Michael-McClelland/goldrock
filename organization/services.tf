resource "aws_guardduty_organization_admin_account" "aws_guardduty_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_securityhub_organization_admin_account" "aws_securityhub_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [aws_securityhub_account.aws_securityhub_management_account]
}

#Workaround for SecurityHub Central Configuration
resource "aws_securityhub_account" "aws_securityhub_management_account" {
  auto_enable_controls      = true
  control_finding_generator = "STANDARD_CONTROL"
  enable_default_standards  = false
}

resource "aws_detective_organization_admin_account" "aws_detective_organization_admin_account" {
  account_id = module.organization_structure.all_accounts.goldrock-securityservices.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_macie2_organization_admin_account" "aws_macie2_organization_admin_account" {
  admin_account_id = module.organization_structure.all_accounts.goldrock-securityservices.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_delegated_administrator" "access_analyzer" {
  account_id        = module.organization_structure.all_accounts.goldrock-securityservices.id
  service_principal = "access-analyzer.amazonaws.com"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_delegated_administrator" "cloudtrail" {
  account_id        = module.organization_structure.all_accounts.goldrock-securityservices.id
  service_principal = "cloudtrail.amazonaws.com"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_service_linked_role" "cloudtrail" {
  depends_on = [aws_organizations_delegated_administrator.cloudtrail]
  aws_service_name = "cloudtrail.amazonaws.com"
}