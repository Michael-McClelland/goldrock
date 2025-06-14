output "security_account" {
  value = aws_organizations_account.account["goldrock-securityservices"].id
}

output "all_accounts_with_policies" {
  value = local.all_account_attributes
}

output "all_organizational_units_with_policies" {
  value = local.all_ou_attributes
}
