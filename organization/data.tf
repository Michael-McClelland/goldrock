data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "session" { arn = data.aws_caller_identity.current.arn }
data "aws_organizations_organization" "organization" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.organization.roots[0].id
}

data "aws_organizations_organizational_unit_descendant_accounts" "org" {
  for_each  = { for ou in data.aws_organizations_organizational_units.ou.children : ou.name => ou.id }
  parent_id = each.value
}

data "aws_kms_key" "goldrock_tfstate" {
  key_id = "alias/goldrock-tfstate" 
}