resource "aws_s3_bucket" "config" {
  bucket = "goldrock-configservice-${data.aws_caller_identity.current.id}-${data.aws_region.current.id}"
}

resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id
  policy = data.aws_iam_policy_document.config.json
}

data "aws_iam_policy_document" "config" {


  statement {
    sid    = "getbucketacl-config"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:GetEncryptionConfiguration",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.config.arn}"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        "${data.aws_organizations_organization.organization.id}"
      ]
    }

  }

  statement {
    sid    = "putobject-config"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.config.arn}/${data.aws_organizations_organization.organization.id}/AWSLogs/$${aws:SourceAccount}/Config/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        "${data.aws_organizations_organization.organization.id}"
      ]
    }

  }

  # statement {
  #   effect = "Deny"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   actions = [
  #     "s3:PutObject",
  #   ]

  #   resources = [
  #     "${aws_s3_bucket.config.arn}/*"
  #   ]
  #   condition {
  #     test     = "StringNotEqualsIfExists"
  #     variable = "s3:x-amz-server-side-encryption"
  #     values   = ["aws:kms"]
  #   }
  #   condition {
  #     test     = "Null"
  #     variable = "s3:x-amz-server-side-encryption"
  #     values   = ["false"]
  #   }
  # }

  # statement {
  #   effect = "Deny"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   actions = [
  #     "s3:PutObject",
  #   ]

  #   resources = [
  #     "${aws_s3_bucket.config.arn}/*"
  #   ]
  #   condition {
  #     test     = "StringNotEquals"
  #     variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
  #     values   = [aws_kms_replica_key.key.arn]
  #   }
  # }

  # statement {
  #   effect = "Deny"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   actions = [
  #     "s3:BypassGovernanceRetention",
  #     "s3:DeleteBucket",
  #     "s3:DeleteBucketPolicy",
  #     "s3:DeleteBucketWebsite",
  #     "s3:PutAccelerateConfiguration",
  #     "s3:PutAnalyticsConfiguration",
  #     "s3:PutBucketAcl",
  #     "s3:PutBucketCORS",
  #     "s3:PutBucketLogging",
  #     "s3:PutBucketNotification",
  #     "s3:PutBucketOwnershipControls",
  #     "s3:PutBucketPolicy",
  #     "s3:PutBucketPublicAccessBlock",
  #     "s3:PutBucketRequestPayment",
  #     "s3:PutBucketVersioning",
  #     "s3:PutBucketWebsite",
  #     "s3:PutEncryptionConfiguration",
  #     "s3:PutInventoryConfiguration",
  #     "s3:PutLifecycleConfiguration",
  #     "s3:PutMetricsConfiguration",
  #     "s3:PutReplicationConfiguration",

  #   ]

  #   resources = [
  #     "${aws_s3_bucket.config.arn}/*",
  #     "${aws_s3_bucket.config.arn}",
  #   ]

  #   condition {
  #     test     = "StringNotEquals"
  #     variable = "aws:PrincipalAccount"
  #     values = [
  #       data.aws_caller_identity.current.account_id
  #     ]
  #   }
  # }

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
      "${aws_s3_bucket.config.arn}/*",
      "${aws_s3_bucket.config.arn}",
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
      "${aws_s3_bucket.config.arn}/*",
      "${aws_s3_bucket.config.arn}",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

}

resource "aws_s3_bucket_ownership_controls" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_replica_key.key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }

}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket = aws_s3_bucket.config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "config" {
  bucket = aws_s3_bucket.config.id

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

