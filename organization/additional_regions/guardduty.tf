resource "aws_guardduty_organization_admin_account" "aws_guardduty_organization_admin_account" {
  admin_account_id = module.organization_structure.security_account
  lifecycle {
    prevent_destroy = true
  }
}