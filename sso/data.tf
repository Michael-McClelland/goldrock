data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" { arn = data.aws_caller_identity.current.arn }
data "aws_organizations_organization" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_ssoadmin_instances" "current" {}

locals {
  all_accounts = { for account in data.aws_organizations_organization.current.accounts :
  account.name => account.id }
}

#####################
#####################
#####################
# Loops through a series of local variables and data resources to build a dictionary containing facts regarding the 
# structure of the orgnization to include each organizational unit and a set of attributes for each.
# Utiling the the output values of the dictionary one will be able to explicitly target the assignment of a permission set
# to a set of member accounts based on their placement within the organizational structure."
# The pemissions set "usc-lz-ou-demo-deployment" demonstrates how to utilize the resources to target an organizational
# unit for a permission set. Please see the file organizational_unit_deployment_demo.tf.
data "aws_organizations_organization" "organization" {}
locals {
  roots_basic = {
    for root in data.aws_organizations_organization.organization.roots :
    root.id => merge(root, {
      parent_id = data.aws_organizations_organization.organization.id
      }
    )
  }
}
data "aws_organizations_organizational_unit_child_accounts" "roots" {
  for_each  = local.roots_basic
  parent_id = each.value.id
}

data "aws_organizations_organizational_units" "level_0" {
  for_each  = local.roots_basic
  parent_id = each.value.id
}
locals {
  level_0_ous_basic = merge([
    for id, v in data.aws_organizations_organizational_units.level_0 :
    {
      for child in v.children :
      child.id => merge(child, {
        parent_id = id
      })
    }
  ]...)
}
data "aws_organizations_organizational_unit_child_accounts" "level_0" {
  for_each  = local.level_0_ous_basic
  parent_id = each.value.id
}

data "aws_organizations_organizational_units" "level_1" {
  for_each  = local.level_0_ous_basic
  parent_id = each.value.id
}
locals {
  level_1_ous_basic = merge([
    for id, v in data.aws_organizations_organizational_units.level_1 :
    {
      for child in v.children :
      child.id => merge(child, {
        parent_id = id
      })
    }
  ]...)
}
data "aws_organizations_organizational_unit_child_accounts" "level_1" {
  for_each  = local.level_1_ous_basic
  parent_id = each.value.id
}

data "aws_organizations_organizational_units" "level_2" {
  for_each  = local.level_1_ous_basic
  parent_id = each.value.id
}
locals {
  level_2_ous_basic = merge([
    for id, v in data.aws_organizations_organizational_units.level_2 :
    {
      for child in v.children :
      child.id => merge(child, {
        parent_id = id
      })
    }
  ]...)
}
data "aws_organizations_organizational_unit_child_accounts" "level_2" {
  for_each  = local.level_2_ous_basic
  parent_id = each.value.id
}

data "aws_organizations_organizational_units" "level_3" {
  for_each  = local.level_2_ous_basic
  parent_id = each.value.id
}
locals {
  level_3_ous_basic = merge([
    for id, v in data.aws_organizations_organizational_units.level_3 :
    {
      for child in v.children :
      child.id => merge(child, {
        parent_id = id
      })
    }
  ]...)
}
data "aws_organizations_organizational_unit_child_accounts" "level_3" {
  for_each  = local.level_3_ous_basic
  parent_id = each.value.id
}

data "aws_organizations_organizational_units" "level_4" {
  for_each  = local.level_3_ous_basic
  parent_id = each.value.id
}
locals {
  level_4_ous_basic = merge([
    for id, v in data.aws_organizations_organizational_units.level_4 :
    {
      for child in v.children :
      child.id => merge(child, {
        parent_id = id
      })
    }
  ]...)
}
data "aws_organizations_organizational_unit_child_accounts" "level_4" {
  for_each  = local.level_4_ous_basic
  parent_id = each.value.id
}

data "aws_organizations_organizational_units" "level_5" {
  for_each  = local.level_4_ous_basic
  parent_id = each.value.id
}
locals {
  level_5_ous_basic = merge([
    for id, v in data.aws_organizations_organizational_units.level_5 :
    {
      for child in v.children :
      child.id => merge(child, {
        parent_id       = id
      })
    }
  ]...)
}
data "aws_organizations_organizational_unit_child_accounts" "level_5" {
  for_each  = local.level_5_ous_basic
  parent_id = each.value.id
}

locals {

  organization = {
    id        = data.aws_organizations_organization.organization.id
    name      = "Organization"
    arn       = data.aws_organizations_organization.organization.arn
    parent_id = null
  }

  ou_child_ou_ids = merge(
    {
      (local.organization.id) = data.aws_organizations_organization.organization.roots.*.id
    }
    , {
      for parent_id, ou_set in merge(
        data.aws_organizations_organizational_units.level_0,
        data.aws_organizations_organizational_units.level_1,
        data.aws_organizations_organizational_units.level_2,
        data.aws_organizations_organizational_units.level_3,
        data.aws_organizations_organizational_units.level_4,
        data.aws_organizations_organizational_units.level_5,
      ) :
      parent_id => [
        for ou in ou_set.children :
        ou.id
      ]
  })

  all_child_accounts_by_ou_id = {
    for ou_id, data_source in merge(
      {
        (local.organization.id) = {
          accounts = []
        }
      },
      data.aws_organizations_organizational_unit_child_accounts.roots,
      data.aws_organizations_organizational_unit_child_accounts.level_0,
      data.aws_organizations_organizational_unit_child_accounts.level_1,
      data.aws_organizations_organizational_unit_child_accounts.level_2,
      data.aws_organizations_organizational_unit_child_accounts.level_3,
      data.aws_organizations_organizational_unit_child_accounts.level_4,
      data.aws_organizations_organizational_unit_child_accounts.level_5,
    ) :
    ou_id => {
      for account in data_source.accounts :
      account.id => merge(account, {
        parent_id = ou_id
      })
      if !contains(["SUSPENDED", "PENDING_CLOSURE"], account.status)
    }
  }

  ous_basic = merge(
    {
      (local.organization.id) = local.organization
    },
    local.roots_basic,
    local.level_0_ous_basic,
    local.level_1_ous_basic,
    local.level_2_ous_basic,
    local.level_3_ous_basic,
    local.level_4_ous_basic,
    local.level_5_ous_basic,
  )

  ous_with_parents = {
    for ou_id, ou in local.ous_basic :
    ou_id => merge(ou, {
      parent_arn = ou.parent_id == null ? null : local.ous_basic[ou.parent_id].arn
    })
  }

  root_ous_with_ancestors = {
    for id in keys(local.roots_basic) :
    id => merge(local.ous_with_parents[id], {
      ancestor_ou_ids = [
        local.ous_with_parents[id].parent_id
      ]
    })
  }

  level_0_ous_with_ancestors = {
    for id in keys(local.level_0_ous_basic) :
    id => merge(local.ous_with_parents[id], {
      ancestor_ou_ids = concat([local.ous_with_parents[id].parent_id], local.root_ous_with_ancestors[local.ous_with_parents[id].parent_id].ancestor_ou_ids)
    })
  }

  level_1_ous_with_ancestors = {
    for id in keys(local.level_1_ous_basic) :
    id => merge(local.ous_with_parents[id], {
      ancestor_ou_ids = concat([local.ous_with_parents[id].parent_id], local.level_0_ous_with_ancestors[local.ous_with_parents[id].parent_id].ancestor_ou_ids)
    })
  }

  level_2_ous_with_ancestors = {
    for id in keys(local.level_2_ous_basic) :
    id => merge(local.ous_with_parents[id], {
      ancestor_ou_ids = concat([local.ous_with_parents[id].parent_id], local.level_1_ous_with_ancestors[local.ous_with_parents[id].parent_id].ancestor_ou_ids)
    })
  }

  level_3_ous_with_ancestors = {
    for id in keys(local.level_3_ous_basic) :
    id => merge(local.ous_with_parents[id], {
      ancestor_ou_ids = concat([local.ous_with_parents[id].parent_id], local.level_2_ous_with_ancestors[local.ous_with_parents[id].parent_id].ancestor_ou_ids)
    })
  }

  level_4_ous_with_ancestors = {
    for id in keys(local.level_4_ous_basic) :
    id => merge(local.ous_with_parents[id], {
      ancestor_ou_ids = concat([local.ous_with_parents[id].parent_id], local.level_3_ous_with_ancestors[local.ous_with_parents[id].parent_id].ancestor_ou_ids)
    })
  }

  level_5_ous_with_ancestors = {
    for id in keys(local.level_5_ous_basic) :
    id => merge(local.ous_with_parents[id], {
      ancestor_ou_ids = concat([local.ous_with_parents[id].parent_id], local.level_4_ous_with_ancestors[local.ous_with_parents[id].parent_id].ancestor_ou_ids)
    })
  }

  ous_with_ancestors = merge(
    {
      (local.organization.id) = merge(local.organization, {
        ancestor_ou_ids = []
      })
    },
    local.root_ous_with_ancestors,
    local.level_0_ous_with_ancestors,
    local.level_1_ous_with_ancestors,
    local.level_2_ous_with_ancestors,
    local.level_3_ous_with_ancestors,
    local.level_4_ous_with_ancestors,
    local.level_5_ous_with_ancestors,
  )

  ous_with_children = {
    for ou_id, ou in local.ous_with_ancestors :
    ou_id => merge(ou, {
      ancestor_ou_arns = [
        for ancestor_id in local.ous_with_ancestors[ou_id].ancestor_ou_ids :
        local.ous_with_ancestors[ancestor_id].arn
      ]
      org_path     = join("/", concat(reverse(ou.ancestor_ou_ids), [ou_id]))
      child_ou_ids = local.ou_child_ou_ids[ou_id]
      child_ou_arns = [
        for child_ou_id in local.ou_child_ou_ids[ou_id] :
        local.ous_with_ancestors[child_ou_id].arn
      ]
    })
  }

  level_5_ous_with_descendants = {
    for ou_id in keys(local.level_5_ous_basic) :
    ou_id => merge(local.ous_with_children[ou_id], {
      descendant_ou_ids      = local.ous_with_children[ou_id].child_ou_ids
      descendant_account_ids = keys(local.all_child_accounts_by_ou_id[ou_id])
    })
  }

  level_4_ous_with_descendants = {
    for ou_id in keys(local.level_4_ous_basic) :
    ou_id => merge(local.ous_with_children[ou_id], {
      descendant_ou_ids = concat(local.ous_with_children[ou_id].child_ou_ids, flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_5_ous_with_descendants[child_ou_id].descendant_ou_ids
      ]))
      descendant_account_ids = concat(keys(local.all_child_accounts_by_ou_id[ou_id]), flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_5_ous_with_descendants[child_ou_id].descendant_account_ids
      ]))
    })
  }

  level_3_ous_with_descendants = {
    for ou_id in keys(local.level_3_ous_basic) :
    ou_id => merge(local.ous_with_children[ou_id], {
      descendant_ou_ids = concat(local.ous_with_children[ou_id].child_ou_ids, flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_4_ous_with_descendants[child_ou_id].descendant_ou_ids
      ]))
      descendant_account_ids = concat(keys(local.all_child_accounts_by_ou_id[ou_id]), flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_4_ous_with_descendants[child_ou_id].descendant_account_ids
      ]))
    })
  }

  level_2_ous_with_descendants = {
    for ou_id in keys(local.level_2_ous_basic) :
    ou_id => merge(local.ous_with_children[ou_id], {
      descendant_ou_ids = concat(local.ous_with_children[ou_id].child_ou_ids, flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_3_ous_with_descendants[child_ou_id].descendant_ou_ids
      ]))
      descendant_account_ids = concat(keys(local.all_child_accounts_by_ou_id[ou_id]), flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_3_ous_with_descendants[child_ou_id].descendant_account_ids
      ]))
    })
  }

  level_1_ous_with_descendants = {
    for ou_id in keys(local.level_1_ous_basic) :
    ou_id => merge(local.ous_with_children[ou_id], {
      descendant_ou_ids = concat(local.ous_with_children[ou_id].child_ou_ids, flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_2_ous_with_descendants[child_ou_id].descendant_ou_ids
      ]))
      descendant_account_ids = concat(keys(local.all_child_accounts_by_ou_id[ou_id]), flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_2_ous_with_descendants[child_ou_id].descendant_account_ids
      ]))
    })
  }

  level_0_ous_with_descendants = {
    for ou_id in keys(local.level_0_ous_basic) :
    ou_id => merge(local.ous_with_children[ou_id], {
      descendant_ou_ids = concat(local.ous_with_children[ou_id].child_ou_ids, flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_1_ous_with_descendants[child_ou_id].descendant_ou_ids
      ]))
      descendant_account_ids = concat(keys(local.all_child_accounts_by_ou_id[ou_id]), flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_1_ous_with_descendants[child_ou_id].descendant_account_ids
      ]))
    })
  }

  root_ous_with_descendants = {
    for ou_id in keys(local.roots_basic) :
    ou_id => merge(local.ous_with_children[ou_id], {
      descendant_ou_ids = concat(local.ous_with_children[ou_id].child_ou_ids, flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_0_ous_with_descendants[child_ou_id].descendant_ou_ids
      ]))
      descendant_account_ids = concat(keys(local.all_child_accounts_by_ou_id[ou_id]), flatten([
        for child_ou_id in local.ous_with_children[ou_id].child_ou_ids :
        local.level_0_ous_with_descendants[child_ou_id].descendant_account_ids
      ]))
    })
  }

  organization_with_descendants = {
    (local.organization.id) = merge(local.ous_with_children[local.organization.id], {
      descendant_ou_ids = concat(local.ous_with_children[local.organization.id].child_ou_ids, flatten([
        for child_ou_id in local.ous_with_children[local.organization.id].child_ou_ids :
        local.root_ous_with_descendants[child_ou_id].descendant_ou_ids
      ]))
      descendant_account_ids = concat(keys(local.all_child_accounts_by_ou_id[local.organization.id]), flatten([
        for child_ou_id in local.ous_with_children[local.organization.id].child_ou_ids :
        local.root_ous_with_descendants[child_ou_id].descendant_account_ids
      ]))
    })
  }
}

locals {
  accounts_by_id = merge([
    for ou_id, child_accounts in local.all_child_accounts_by_ou_id :
    {
      for id, account in child_accounts :
      id => merge(account, {
        ancestor_ou_ids  = concat([ou_id], local.ous_with_children[ou_id].ancestor_ou_ids)
        ancestor_ou_arns = concat([local.ous_with_children[ou_id].arn], local.ous_with_children[ou_id].ancestor_ou_arns)
      })
    }
  ]...)

  ous_by_id = {
    for ou_id, ou in merge(
      local.organization_with_descendants,
      local.root_ous_with_descendants,
      local.level_0_ous_with_descendants,
      local.level_1_ous_with_descendants,
      local.level_2_ous_with_descendants,
      local.level_3_ous_with_descendants,
      local.level_4_ous_with_descendants,
      local.level_5_ous_with_descendants,
    ) :
    ou_id => merge(ou, {
      descendant_ou_arns = [
        for descendant_ou_id in ou.descendant_ou_ids :
        local.ous_with_children[descendant_ou_id].arn
      ]
      descendant_account_arns = [
        for descendant_account_id in ou.descendant_account_ids :
        local.accounts_by_id[descendant_account_id].arn
      ]
    })
  }
}


# variable referenced by the final output in the outputs file
# a list of accounts for a given OU can be addressed in the following manner
# local.ous_by_name.Infrastructure.descendant_account_ids where Infrastructure 
# is the name of the desired organizational unit to target a permission set assignment to

# locals {

#   ous_by_name = {
#     for k, v in local.ous_by_id :
#     (v.name) => v
#   }
# }
