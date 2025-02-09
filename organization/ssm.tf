resource "aws_ssm_parameter" "goldrock_security_account_id" {
  name        = "/${var.name}/security_account_id"
  description = "goldrock security account id"
  type        = "SecureString"
  tier        = "Advanced"
  value       = module.organization_structure.security_account
  key_id      = data.aws_kms_key.goldrock_tfstate.arn
}

