data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "organization" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_ssm_parameter" "security_account_id" {
  name = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.id}:${data.aws_organizations_organization.organization.master_account_id}:parameter/goldrock/security_account_id"
}
data "aws_iam_role" "configservice" {
  name = "AWSServiceRoleForConfig"
}

#aws-service-role/config.amazonaws.com/