resource "aws_s3_bucket" "cloudtrail" {
  bucket = "goldrock-cloudtrail-${data.aws_caller_identity.current.id}-${data.aws_region.current.id}"
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json
}


data "aws_iam_policy_document" "cloudtrail" {

  statement {
    sid    = "getbucketacl-cloudtrail"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail.arn}"
    ]
    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:SourceOrgID"
    #   values = [
    #     "${data.aws_organizations_organization.current.id}"
    #   ]
    # }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.id}:${data.aws_organizations_organization.current.master_account_id}:trail/goldrock"
      ]
    }
  }

  statement {
    sid    = "putobject-cloudtrail"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.cloudtrail.arn}/goldrock/AWSLogs/${data.aws_organizations_organization.current.id}/*",
      "${aws_s3_bucket.cloudtrail.arn}/goldrock/AWSLogs/${data.aws_organizations_organization.current.master_account_id}/*"
    ]
    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:SourceOrgID"
    #   values = [
    #     "${data.aws_organizations_organization.current.id}"
    #   ]
    # }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.id}:${data.aws_organizations_organization.current.master_account_id}:trail/goldrock"
      ]
    }
  }

  # statement {
  #   sid    = "puts"
  #   effect = "Allow"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   actions = [
  #     "s3:GetObject",
  #     "s3:ListBucket",
  #     "s3:PutObject"
  #   ]

  #   resources = [
  #     "${aws_s3_bucket.cloudtrail.arn}/*",
  #     "${aws_s3_bucket.cloudtrail.arn}",
  #   ]
  #   condition {
  #     test     = "StringEquals"
  #     variable = "aws:PrincipalOrgID"
  #     values = [
  #       data.aws_organizations_organization.current.id
  #     ]
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
  #     "${aws_s3_bucket.cloudtrail.arn}/*"
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
  #     "${aws_s3_bucket.cloudtrail.arn}/*"
  #   ]
  #   condition {
  #     test     = "StringNotEquals"
  #     variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
  #     values   = [aws_kms_key.key.arn]
  #   }
  # }

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
      "${aws_s3_bucket.cloudtrail.arn}/*",
      "${aws_s3_bucket.cloudtrail.arn}",
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
      "${aws_s3_bucket.cloudtrail.arn}/*",
      "${aws_s3_bucket.cloudtrail.arn}",
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
      "${aws_s3_bucket.cloudtrail.arn}/*",
      "${aws_s3_bucket.cloudtrail.arn}",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

}

resource "aws_s3_bucket_ownership_controls" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }

}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

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
        "${data.aws_organizations_organization.current.id}"
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
      "${aws_s3_bucket.config.arn}/${data.aws_organizations_organization.current.id}/AWSLogs/$${aws:SourceAccount}/Config/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        "${data.aws_organizations_organization.current.id}"
      ]
    }

  }

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
      "${aws_s3_bucket.config.arn}/*",
      "${aws_s3_bucket.config.arn}",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.current.id
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
  #     values   = [aws_kms_key.key.arn]
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

  # statement {
  #   effect = "Deny"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   actions = [
  #     "s3:*",
  #   ]

  #   resources = [
  #     "${aws_s3_bucket.config.arn}/*",
  #     "${aws_s3_bucket.config.arn}",
  #   ]

  #   condition {
  #     test     = "NumericLessThan"
  #     variable = "s3:TlsVersion"
  #     values   = ["1.2"]
  #   }
  # }

  # statement {
  #   effect = "Deny"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   actions = [
  #     "s3:*",
  #   ]

  #   resources = [
  #     "${aws_s3_bucket.config.arn}/*",
  #     "${aws_s3_bucket.config.arn}",
  #   ]

  #   condition {
  #     test     = "Bool"
  #     variable = "aws:SecureTransport"
  #     values   = ["false"]
  #   }
  # }

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
      kms_master_key_id = aws_kms_key.key.arn
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

