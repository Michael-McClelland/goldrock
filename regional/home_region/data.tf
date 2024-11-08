data "aws_caller_identity" "caller" {}
data "aws_organizations_organization" "current" {}
data "aws_partition" "partition" {}
data "aws_region" "current" {}
data "aws_ssm_parameter" "security_account_id" {
  name = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/goldrock/security_account_id"
}