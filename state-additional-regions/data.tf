data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" { arn = data.aws_caller_identity.current.arn }
data "aws_organizations_organization" "organization" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_kms_key" "multiregionkey" {
  key_id = "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:alias/goldrock-tfstate"
}