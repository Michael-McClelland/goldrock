resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}-tfstate-${data.aws_caller_identity.current.id}-${data.aws_region.current.id}"
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
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/$${aws:PrincipalAccount}/*",
      "${aws_s3_bucket.bucket.arn}",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.organization.id
      ]
    }
  }


  statement {
    sid    = "deletelocks"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/$${aws:PrincipalAccount}/*.tflock",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.organization.id
      ]
    }
  }

  statement {
    sid    = "prevent_delete_not_locks"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteObject"
    ]

    not_resources = [
      "${aws_s3_bucket.bucket.arn}/*.tflock",
    ]
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
      values   = [aws_kms_replica_key.replica.arn]
    }
  }

  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    not_actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"

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
      kms_master_key_id = aws_kms_replica_key.replica.arn
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

    filter {
      prefix = ""
    }
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
    sid = "SSMPermissions"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:PARAMETER_ARN"
      values = [
        "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/${var.name}/security_account_id",
      ]
    }
  }

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
        data.aws_organizations_organization.organization.id
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
        data.aws_organizations_organization.organization.id
      ]
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
      values   = ["${data.aws_organizations_organization.organization.id}"]
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
      values   = ["${data.aws_organizations_organization.organization.id}"]
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
        "${data.aws_organizations_organization.organization.id}"
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
      values   = ["${data.aws_organizations_organization.organization.id}"]
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

resource "aws_kms_replica_key" "replica" {
  description                        = var.name
  deletion_window_in_days            = 30
  bypass_policy_lockout_safety_check = false
  enabled                            = true
  policy                             = data.aws_iam_policy_document.keypolicy.json
  primary_key_arn                    = data.aws_kms_key.multiregionkey.multi_region_configuration[0].primary_key[0].arn
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.name}-tfstate"
  target_key_id = aws_kms_replica_key.replica.key_id
}
