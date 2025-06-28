# Data source to get all AWS Organizations resource control policies
data "aws_organizations_policies" "resource_control_policies" {
  filter = "RESOURCE_CONTROL_POLICY"
}

# Data source to get individual RCP policy details
data "aws_organizations_policy" "resource_control_policies" {
  for_each = toset(data.aws_organizations_policies.resource_control_policies.ids)
  
  policy_id = each.value
}

locals {
  # Create a map of RCP policy names to policy IDs
  rcp_policy_name_to_id_map = {
    for id, policy in data.aws_organizations_policy.resource_control_policies : policy.name => policy.id
  }

  # Create a flattened list of all RCP policy attachments for OUs
  ou_rcp_policy_attachments = flatten([
    for ou_key, ou in local.all_ou_attributes : [
      for policy_name in ou.resource_control_policies : {
        target_id   = ou.id
        policy_name = policy_name
        key         = "${ou_key}-${policy_name}"
      } if contains(keys(local.rcp_policy_name_to_id_map), policy_name)
    ]
  ])

  # Create a flattened list of all RCP policy attachments for accounts
  account_rcp_policy_attachments = flatten([
    for account_key, account in local.all_account_attributes : [
      for policy_name in account.resource_control_policies : {
        target_id   = account.id
        policy_name = policy_name
        key         = "${account_key}-${policy_name}"
      } if contains(keys(local.rcp_policy_name_to_id_map), policy_name)
    ]
  ])

  # Combine both lists for a single resource to handle all RCP attachments
  all_rcp_policy_attachments = concat(local.ou_rcp_policy_attachments, local.account_rcp_policy_attachments)
}

# Use for_each to create RCP policy attachments for all OUs and accounts
resource "aws_organizations_policy_attachment" "rcp_policy_attachments" {
  for_each = { for attachment in local.all_rcp_policy_attachments : attachment.key => attachment }

  policy_id = local.rcp_policy_name_to_id_map[each.value.policy_name]
  target_id = each.value.target_id

  # Add a dependency on the organization to ensure it exists before attaching policies
  depends_on = [
    aws_organizations_organizational_unit.level_1_ous,
    aws_organizations_organizational_unit.level_2_ous,
    aws_organizations_organizational_unit.level_3_ous,
    aws_organizations_organizational_unit.level_4_ous,
    aws_organizations_organizational_unit.level_5_ous,
    aws_organizations_account.account
  ]
}