resource "aws_cloudtrail" "cloudtrail" {
  provider                      = aws.cloudtrail
  name                          = "goldrock"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  s3_key_prefix                 = "goldrock"
  kms_key_id                    = aws_kms_key.key.arn

  event_selector {

    include_management_events = true
    read_write_type           = "All"
  }
}

provider "aws" {
  alias   = "cloudtrail"

  assume_role {
    role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_organizations_organization.organization.master_account_id}:role/goldrock-cloudtrail-management"
  }
}