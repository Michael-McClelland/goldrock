variable "securityhub_full_deploy" {
  description = "If set to true will deploy Security Hub"
  type   = bool
  default = false
}

variable "home_region_cmk_arn" {
  description = "arn of home region cmk"
  type   = string
}