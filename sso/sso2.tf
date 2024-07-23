# module "aws-iam-identity-center2" {
#   source = "git::https://github.com/aws-ia/terraform-aws-iam-identity-center.git"

#   sso_groups = {
#     splunk_team : {
#       group_name        = "splunk_team"
#       group_description = "Splunk_Team"
#     },
#     chno : {
#       group_name        = "chno"
#       group_description = "CHNO"
#     },
#     itso_testers : {
#       group_name        = "itso_testers"
#       group_description = "ITSO_Testers"
#     },
#   }

#   sso_users = {
#     chris_tribie : {
#       group_membership = ["splunk_team"]
#       user_name        = "chris_tribie"
#       given_name       = "chris"
#       family_name      = "tribie"
#       email            = "Chris_Tribie@ao.example.com"
#     },
#     chandra_chitturi_naga_rama : {
#       group_membership = ["splunk_team"]
#       user_name        = "chandra_chitturi_naga_rama"
#       given_name       = "Chandra"
#       family_name      = "Chitturi Naga Rama"
#       email            = "CHANDRA_CHITTURINAGARAMA@ao.example.com"
#     },
#     siddeswari_thunuguntla : {
#       group_membership = ["splunk_team"]
#       user_name        = "siddeswari_thunuguntla"
#       given_name       = "Siddeswari"
#       family_name      = "Thunuguntla"
#       email            = "Siddeswari_Thunuguntla@ao.example.com"
#     },
#     dillon_saylor : {
#       group_membership = ["splunk_team"]
#       user_name        = "dillon_saylor"
#       given_name       = "Dillon"
#       family_name      = "Saylor"
#       email            = "dillon_saylor@ao.example.com"
#     },
#     joshua_anderson : {
#       group_membership = ["splunk_team"]
#       user_name        = "joshua_anderson"
#       given_name       = "Joshua"
#       family_name      = "Anderson"
#       email            = "Joshua_Anderson@ao.example.com"
#     },
#     robert_mcatee : {
#       group_membership = ["chno"]
#       user_name        = "robert_mcatee"
#       given_name       = "Robert"
#       family_name      = "McAtee"
#       email            = "Robert_McAtee@ao.example.com"
#     },
#     greg_wilson : {
#       group_membership = ["chno"]
#       user_name        = "greg_wilson"
#       given_name       = "Greg"
#       family_name      = "Wilson"
#       email            = "Greg_Wilson@aotx.example.com"
#     },
#     cliff_heuer : {
#       group_membership = ["chno"]
#       user_name        = "cliff_heuer"
#       given_name       = "Cliff"
#       family_name      = "Heuer"
#       email            = "Cliff_Heuer@ao.example.com"
#     },
#     don_snider : {
#       group_membership = ["chno"]
#       user_name        = "don_snider"
#       given_name       = "Don"
#       family_name      = "Snider"
#       email            = "Don_Snider@ao.example.com"
#     },
#     aaron_stackpole : {
#       group_membership = ["chno"]
#       user_name        = "aaron_stackpole"
#       given_name       = "Aaron"
#       family_name      = "Stackpole"
#       email            = "Aaron_Stackpole@aotx.example.com"
#     },
#     jimi_joseph : {
#       group_membership = ["chno"]
#       user_name        = "jimi_joseph"
#       given_name       = "Jimi"
#       family_name      = "Joseph"
#       email            = "jimi_joseph@ao.example.com"
#     },
#     samantha_torres : {
#       group_membership = ["chno"]
#       user_name        = "samantha_torres"
#       given_name       = "Samantha"
#       family_name      = "Torres"
#       email            = "samantha_torres@aotx.example.com"
#     },
#     chris_duffy : {
#       group_membership = ["chno"]
#       user_name        = "chris_duffy"
#       given_name       = "Chris"
#       family_name      = "Duffy"
#       email            = "christopher_duffy@aotx.example.com"
#     },
#     surendra_babu : {
#       group_membership = ["chno"]
#       user_name        = "surendra_babu"
#       given_name       = "Surendra"
#       family_name      = "Babu"
#       email            = "Surendra_Babu@ao.example.com"
#     },
#     nursimha_govardhanam : {
#       group_membership = ["itso_testers"]
#       user_name        = "nursimha_govardhanam"
#       given_name       = "Nursimha"
#       family_name      = "Govardhanam"
#       email            = "nursimha_govardhanam@ao.example.com"
#     },
#     shashankreddy_mavuluru : {
#       group_membership = ["itso_testers"]
#       user_name        = "shashankreddy_mavuluru"
#       given_name       = "Shashankreddy"
#       family_name      = "Mavuluru"
#       email            = "shashankreddy_mavuluru@ao.example.com"
#     },
#     diane_looper : {
#       group_membership = ["itso_testers"]
#       user_name        = "diane_looper"
#       given_name       = "Diane"
#       family_name      = "Looper"
#       email            = "Diane_Looper@ao.example.com"
#     },
#   }

#   permission_sets = {
#     ViewOnlyAccess = {
#       description          = "Provides AWS view only permissions.",
#       session_duration     = "PT1H",
#       aws_managed_policies = [
#         "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
#         ]
#       tags                 = { ManagedBy = "Terraform" }
#     },
#   }

#   account_assignments = {
#     splunk_team : {
#       principal_name  = "splunk_team"     
#       principal_type  = "GROUP"          
#       principal_idp   = "INTERNAL"                                
#       permission_sets = ["ViewOnlyAccess"] 
#       account_ids = data.aws_organizations_organization.current.accounts.*.id
#     },
#     chno : {
#       principal_name  = "chno"
#       principal_type  = "GROUP"
#       principal_idp   = "INTERNAL"
#       permission_sets = ["ViewOnlyAccess"]
#       account_ids = ["398930073421"]
#     },
#     itso_testers : {
#       principal_name  = "itso_testers"
#       principal_type  = "GROUP"
#       principal_idp   = "INTERNAL"
#       permission_sets = ["ViewOnlyAccess"]
#       account_ids = ["398930073421"]
#     },
#   }

# }

