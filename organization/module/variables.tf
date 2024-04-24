variable "organization" {
  description = "The organization"
  type = object({
    accounts = optional(list(object({
      name                              = string,
      key                               = string,
      email                             = string,
      allow_iam_users_access_to_billing = optional(bool, true),
    })), [])
    units = optional(list(object({
      name = string,
      key  = string,
      accounts = optional(list(object({
        name                              = string,
        key                               = string,
        email                             = string,
        allow_iam_users_access_to_billing = optional(bool, true),
      })), [])
      units = optional(list(object({
        name = string,
        key  = string,
        accounts = optional(list(object({
          name                              = string,
          key                               = string,
          email                             = string,
          allow_iam_users_access_to_billing = optional(bool, true),
        })), [])
        units = optional(list(object({
          name = string,
          key  = string,
          accounts = optional(list(object({
            name                              = string,
            key                               = string,
            email                             = string,
            allow_iam_users_access_to_billing = optional(bool, true),
          })), [])
          units = optional(list(object({
            name = string,
            key  = string,
            accounts = optional(list(object({
              name                              = string,
              key                               = string,
              email                             = string,
              allow_iam_users_access_to_billing = optional(bool, true),
            })), [])
            units = optional(list(object({
              name = string,
              key  = string,
              accounts = optional(list(object({
                name                              = string,
                key                               = string,
                email                             = string,
                allow_iam_users_access_to_billing = optional(bool, true),
              })), [])
            })), [])
          })), [])
        })), [])
      })), [])
    })), [])
  })
  nullable = false
  default  = {}
}