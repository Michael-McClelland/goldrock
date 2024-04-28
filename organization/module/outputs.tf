output "all_accounts" {
  value = local.all_account_attributes
}


# output "bd_name" {
#   value = {
#     for k, bd in mso_schema_template_bd.bd : k => bd.name
#   }
# }