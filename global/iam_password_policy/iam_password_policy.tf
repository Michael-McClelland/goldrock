resource "aws_iam_account_password_policy" "password_policy" {
  allow_users_to_change_password = true
  minimum_password_length        = 16
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  require_uppercase_characters   = true
  password_reuse_prevention = 24
  max_password_age = 90
  hard_expiry = true
}
terraform {
  backend "s3" {
  }
}