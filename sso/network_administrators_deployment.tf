locals {
  group_assignments = flatten([
    for user, user_info in local.users : [
      for group in user_info.grouplist : {
        user_name  = user_info.user_name
        assignment = group
        assignment_key = "${user_info.user_name}-${group}"
      }
    ]
  ])
}


locals {
  map_of_assignments = { 
    for item in local.group_assignments : (item.assignment_key) => {
        user_name  = item.user_name
        assignment = item.assignment
    }
  }
}

output "name" {
  value = local.map_of_assignments
}


resource "aws_identitystore_group" "network_adminstrators" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]
  display_name      = "usc-lz-network_adminstrators"
  description       = "usc-lz-network_adminstrators"
}

resource "aws_identitystore_user" "user" {
  for_each          = local.users
  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]

  lifecycle {
    prevent_destroy = true #Assigned to each aws_identitystore_user resource to protect user accounts from destruction
  }

  display_name = "${each.value.given_name} ${each.value.family_name}"
  user_name    = each.value.user_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    primary = true
    type    = "work"
    value   = each.value.email_address
  }
}


resource "aws_identitystore_group_membership" "network_adminstrators_membership" {
  for_each          = local.map_of_assignments
  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]
  group_id          = each.value.assignment
  member_id         = aws_identitystore_user.user["${each.value.user_name}"].user_id
}