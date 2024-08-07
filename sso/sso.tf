module "aws-iam-identity-center" {
  source = "git::https://github.com/aws-ia/terraform-aws-iam-identity-center.git"

  // Create desired GROUPS in IAM Identity Center
  sso_groups = {
    admin : {
      group_name        = "admin"
      group_description = "admin IAM Identity Center Group"
    },
    Dev : {
      group_name        = "Dev"
      group_description = "Dev IAM Identity Center Group"
    },
    QA : {
      group_name        = "QA"
      group_description = "QA IAM Identity Center Group"
    },
    Audit : {
      group_name        = "Audit"
      group_description = "Audit IAM Identity Center Group"
    },
  }

  // Create desired USERS in IAM Identity Center
  sso_users = {
    demo : {
      group_membership = ["admin"]
      user_name        = "demo"
      given_name       = "demo"
      family_name      = "user"
      email            = "mccmcc+demo@amazon.com"
    }
    michael_mcclelland : {
      group_membership = ["admin", "Dev", "QA", "Audit"]
      user_name        = "michael_mcclelland"
      given_name       = "Michael"
      family_name      = "McClelland"
      email            = "mccmcc@amazon.com"
    }
  }

  // Create permissions sets backed by AWS managed policies
  permission_sets = {
    AdministratorAccess = {
      description          = "Provides AWS full access permissions.",
      session_duration     = "PT12H", // how long until session expires - this means 4 hours. max is 12 hours
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
        ]
      tags                 = { ManagedBy = "Terraform" }
    },
    ViewOnlyAccess = {
      description          = "Provides AWS view only permissions.",
      session_duration     = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
        ]
      tags                 = { ManagedBy = "Terraform" }
    },
    CustomPermissionAccess = {
      description          = "Provides Basic Readonly",
      session_duration     = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      inline_policy        = data.aws_iam_policy_document.CustomPermissionInlinePolicy.json

      // Only either managed_policy_arn or customer_managed_policy_reference can be specified.
      // Before using customer_managed_policy_reference, first deploy the policy to the account.
      // Don't in-place managed_policy_arn to/from customer_managed_policy_reference, delete it once.
      permissions_boundary = {
        managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"

        # customer_managed_policy_reference = {
        #   name = "ExamplePermissionsBoundaryPolicy"
        #   // path = "/"
        # }
      }
      tags                 = { ManagedBy = "Terraform" }
    },
  }

  account_assignments = {
    admin : {
      principal_name  = "admin"                                   # name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                   # principal type (user or group) you wish to have access to the account(s)
      principal_idp   = "INTERNAL"                                # type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess"] # permissions the user/group will have in the account(s)
      account_ids = data.aws_organizations_organization.current.accounts.*.id
    },
    Audit : {
      principal_name  = "Audit"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["ViewOnlyAccess"]
      account_ids = data.aws_organizations_organization.current.accounts.*.id
    },
  }

}


data "aws_iam_policy_document" "CustomPermissionInlinePolicy" {


  statement {

    effect = "Allow"
    actions = [
      "artifact:*"
    ]

    resources = [
      "*"
    ]

  }
}