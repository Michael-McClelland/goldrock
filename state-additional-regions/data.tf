data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" { arn = data.aws_caller_identity.current.arn }
data "aws_organizations_organization" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_kms_key" "primary_cmk" {
  key_id = "arn:${data.aws_partition.current.partition}:kms:${var.HOME_REGION}:${data.aws_caller_identity.current.id}:alias/goldrock-tfstate"
}