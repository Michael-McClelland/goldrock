output "security_account" {
  value = aws_organizations_account.account["goldrock-securityservices"].id
}