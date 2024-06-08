resource "aws_cloudtrail" "cloudtrail" {
  name                          = "goldrockCloudTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  kms_key_id                    = aws_kms_key.key.arn
}