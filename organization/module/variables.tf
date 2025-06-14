variable "organization" {
  description = "The organization"
  type = object({
    accounts = optional(list(object({
      name                              = string,
      key                               = string,
      email                             = string,
      allow_iam_users_access_to_billing = optional(bool, true),
      policies                          = optional(list(string), ["FullAWSAccess"]),
    })), [])
    units = optional(list(object({
      name     = string,
      key      = string,
      policies = optional(list(string), ["FullAWSAccess"]),
      accounts = optional(list(object({
        name                              = string,
        key                               = string,
        email                             = string,
        allow_iam_users_access_to_billing = optional(bool, true),
        policies                          = optional(list(string), ["FullAWSAccess"]),
      })), [])
      units = optional(list(object({
        name     = string,
        key      = string,
        policies = optional(list(string), ["FullAWSAccess"]),
        accounts = optional(list(object({
          name                              = string,
          key                               = string,
          email                             = string,
          allow_iam_users_access_to_billing = optional(bool, true),
          policies                          = optional(list(string), ["FullAWSAccess"]),
        })), [])
        units = optional(list(object({
          name     = string,
          key      = string,
          policies = optional(list(string), ["FullAWSAccess"]),
          accounts = optional(list(object({
            name                              = string,
            key                               = string,
            email                             = string,
            allow_iam_users_access_to_billing = optional(bool, true),
            policies                          = optional(list(string), ["FullAWSAccess"]),
          })), [])
          units = optional(list(object({
            name     = string,
            key      = string,
            policies = optional(list(string), ["FullAWSAccess"]),
            accounts = optional(list(object({
              name                              = string,
              key                               = string,
              email                             = string,
              allow_iam_users_access_to_billing = optional(bool, true),
              policies                          = optional(list(string), ["FullAWSAccess"]),
            })), [])
            units = optional(list(object({
              name     = string,
              key      = string,
              policies = optional(list(string), ["FullAWSAccess"]),
              accounts = optional(list(object({
                name                              = string,
                key                               = string,
                email                             = string,
                allow_iam_users_access_to_billing = optional(bool, true),
                policies                          = optional(list(string), ["FullAWSAccess"]),
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
