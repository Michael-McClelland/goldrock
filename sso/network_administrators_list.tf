locals {
  users = {
    michael_mcclelland = {
      user_name     = "michael_mcclelland"
      given_name    = "Michael"
      family_name   = "McClelland"
      email_address = "mccmcc+testuser@amazon.com"
      grouplist = ["${aws_identitystore_group.network_adminstrators.group_id}"]
    }
  }
}