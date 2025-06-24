variable "organization" {
  description = "The organization"
  type = object({
    accounts = optional(list(object({
      name                              = string,
      key                               = string,
      email                             = string,
      allow_iam_users_access_to_billing = optional(bool, true),
      service_control_policies                          = optional(list(string), []),
    })), [])
    units = optional(list(object({
      name     = string,
      key      = string,
      service_control_policies = optional(list(string), []),
      accounts = optional(list(object({
        name                              = string,
        key                               = string,
        email                             = string,
        allow_iam_users_access_to_billing = optional(bool, true),
        service_control_policies                          = optional(list(string), []),
      })), [])
      units = optional(list(object({
        name     = string,
        key      = string,
        service_control_policies = optional(list(string), []),
        accounts = optional(list(object({
          name                              = string,
          key                               = string,
          email                             = string,
          allow_iam_users_access_to_billing = optional(bool, true),
          service_control_policies                          = optional(list(string), []),
        })), [])
        units = optional(list(object({
          name     = string,
          key      = string,
          service_control_policies = optional(list(string), []),
          accounts = optional(list(object({
            name                              = string,
            key                               = string,
            email                             = string,
            allow_iam_users_access_to_billing = optional(bool, true),
            service_control_policies                          = optional(list(string), []),
          })), [])
          units = optional(list(object({
            name     = string,
            key      = string,
            service_control_policies = optional(list(string), []),
            accounts = optional(list(object({
              name                              = string,
              key                               = string,
              email                             = string,
              allow_iam_users_access_to_billing = optional(bool, true),
              service_control_policies                          = optional(list(string), []),
            })), [])
            units = optional(list(object({
              name     = string,
              key      = string,
              service_control_policies = optional(list(string), []),
              accounts = optional(list(object({
                name                              = string,
                key                               = string,
                email                             = string,
                allow_iam_users_access_to_billing = optional(bool, true),
                service_control_policies                          = optional(list(string), []),
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
