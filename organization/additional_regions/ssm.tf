resource "aws_ssm_parameter" "goldrock_security_account_id" {
  name        = "/goldrock/security_account_id"
  description = "goldrock security account id"
  type        = "SecureString"
  tier        = "Advanced"
  value       = var.security_account_id
  key_id      = data.aws_kms_key.goldrock_tfstate.arn
}
