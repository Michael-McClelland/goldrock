resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}-${data.aws_caller_identity.current.id}-${data.aws_region.current.id}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket.json
}

data "aws_iam_policy_document" "bucket" {

  statement {
    sid    = "puts"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/$${aws:PrincipalAccount}/*",
      "${aws_s3_bucket.bucket.arn}",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.current.id
      ]
    }
  }

  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    condition {
      test     = "StringNotEqualsIfExists"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["false"]
    }
  }

  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.key.arn]
    }
  }

  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:BypassGovernanceRetention",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucketWebsite",
      "s3:PutAccelerateConfiguration",
      "s3:PutAnalyticsConfiguration",
      "s3:PutBucketAcl",
      "s3:PutBucketCORS",
      "s3:PutBucketLogging",
      "s3:PutBucketNotification",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketRequestPayment",
      "s3:PutBucketVersioning",
      "s3:PutBucketWebsite",
      "s3:PutEncryptionConfiguration",
      "s3:PutInventoryConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutMetricsConfiguration",
      "s3:PutReplicationConfiguration",

    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      "${aws_s3_bucket.bucket.arn}",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalAccount"
      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }

  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      "${aws_s3_bucket.bucket.arn}",
    ]

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }

  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      "${aws_s3_bucket.bucket.arn}",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }

}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "standard"

    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 180
    }

    abort_incomplete_multipart_upload {

      days_after_initiation = 7
    }
  }

}

data "aws_iam_policy_document" "keypolicy" {

  statement {
    sid = "org-describe"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.current.id
      ]
    }

  }

  statement {
    sid = "s3"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "s3.${data.aws_region.current.id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values = [
        aws_s3_bucket.bucket.arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.current.id
      ]
    }

  }

  statement {
    sid = "optionalAllowUseofKeyforKeygrantsbyDynamoDBforTableswithNamesstartwithprefix"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:CreateGrant"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "dynamodb.${data.aws_region.current.id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:GrantConstraintType"
      values = [
        "EncryptionContextSubset"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:dynamodb:tableName"
      values = [
        "${var.name}*"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:dynamodb:subscriberId"
      values = [
        data.aws_caller_identity.current.id
      ]
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "kms:GrantOperations"
      values = [
        "DescribeKey",
        "Decrypt",
        "Encrypt",
        "GenerateDataKey",
        "ReEncryptFrom",
        "ReEncryptTo",
        "RetireGrant"
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    sid = "DecryptLock"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "dynamodb.${data.aws_region.current.id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:dynamodb:tableName"
      values = [
        "${var.name}*"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["${data.aws_organizations_organization.current.id}"]
    }
  }

  statement {
    sid = "IAMPermissions"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:CancelKeyDeletion",
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:Describe*",
      "kms:Disable*",
      "kms:Enable*",
      "kms:Get*",
      "kms:PutKeyPolicy",
      "kms:ReplicateKey",
      "kms:ScheduleKeyDeletion",
      "kms:SynchronizeMultiRegionKey",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Update*",
      "kms:List*"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["${data.aws_organizations_organization.current.id}"]
    }
  }

  statement {
    sid = "RecoveryPermissions"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:CancelKeyDeletion",
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:Describe*",
      "kms:Disable*",
      "kms:Enable*",
      "kms:Get*",
      "kms:PutKeyPolicy",
      "kms:ReplicateKey",
      "kms:ScheduleKeyDeletion",
      "kms:SynchronizeMultiRegionKey",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Update*",
      "kms:List*"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["${data.aws_organizations_organization.current.id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:role/keyrecoveryrole"
      ]
    }
  }

  statement {
    sid = "AllowMacietoDecryptheKey"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Describe*",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:List*"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:role/aws-service-role/macie.amazonaws.com/AWSServiceRoleForAmazonMacie"]
    }
  }

  statement {
    sid = "AllowConfigandAccessAnalyzertoReadKeyAttributes"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:Describe*",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:List*"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:role/aws-service-role/access-analyzer.amazonaws.com/AWSServiceRoleForAccessAnalyzer",
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
      ]
    }
  }

  statement {
    sid = "DenyNonOrganizationalServiceEncryptionUse"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Deny"
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:SourceOrgID"
      values = [
        "${data.aws_organizations_organization.current.id}"
      ]
    }
    condition {
      test     = "Null"
      variable = "aws:SourceOrgID"
      values   = ["false"]
    }
    condition {
      test     = "BoolIfExists"
      variable = "aws:PrincipalIsAWSService"
      values   = ["true"]
    }
  }

  statement {
    sid = "PreventNonOrganizationalAccess"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Deny"
    actions = [
      "kms:*"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:PrincipalIsAWSService"
      values   = ["false"]
    }
    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:PrincipalOrgID"
      values   = ["${data.aws_organizations_organization.current.id}"]
    }
  }

  statement {
    sid = "MaxDeletionWindow"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Deny"
    actions = [
      "kms:ScheduleKeyDeletion"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "NumericLessThan"
      variable = "kms:ScheduleKeyDeletionPendingWindowInDays"
      values   = ["30"]
    }
  }

  statement {
    sid = "PreventSafetyLockoutBypass"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Deny"
    actions = [
      "kms:PutKeyPolicy"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "Bool"
      variable = "kms:BypassPolicyLockoutSafetyCheck"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "key" {
  description                        = var.name
  deletion_window_in_days            = 30
  key_usage                          = "ENCRYPT_DECRYPT"
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  bypass_policy_lockout_safety_check = false
  is_enabled                         = true
  enable_key_rotation                = true
  multi_region                       = true
  policy                             = data.aws_iam_policy_document.keypolicy.json
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.key.key_id
}


resource "aws_dynamodb_table" "tf_lock_table" {
  name                        = "${var.name}-${data.aws_caller_identity.current.id}-${data.aws_region.current.id}"
  hash_key                    = "LockID"
  read_capacity               = 5
  write_capacity              = 5
  deletion_protection_enabled = true

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
    prevent_destroy = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.key.arn
  }
}

data "aws_iam_policy_document" "dynamodb" {

  statement {
    sid    = "puts"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = [
      aws_dynamodb_table.tf_lock_table.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.current.id
      ]
    }
    condition {
      test     = "ForAllValues:StringLike"
      variable = "dynamodb:LeadingKeys"
      values = [
        "${aws_dynamodb_table.tf_lock_table.id}/*$${aws:PrincipalAccount}*"
      ]
    }
  }

}




resource "aws_dynamodb_resource_policy" "dynamodb" {
  resource_arn = aws_dynamodb_table.tf_lock_table.arn
  policy       = data.aws_iam_policy_document.dynamodb.json
}

resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  max_capacity       = 200
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.tf_lock_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 30
  }
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
  depends_on         = [aws_appautoscaling_policy.dynamodb_table_read_policy]
  max_capacity       = 200
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.tf_lock_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 30
  }
}