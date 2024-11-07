resource "aws_guardduty_organization_admin_account" "aws_guardduty_organization_admin_account" {
  admin_account_id = var.security_account_id
  lifecycle {
    prevent_destroy = true
  }
}