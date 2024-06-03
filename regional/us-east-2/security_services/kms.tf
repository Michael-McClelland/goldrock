data "aws_iam_policy_document" "keypolicy" {

  statement {
    sid = "KMSCloudTrail"
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        "${data.aws_organizations_organization.current.id}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "arn:${data.aws_partition.current.partition}:cloudtrail:${var.management_account_id}:${data.aws_caller_identity.current.id}:trail/goldrockCloudTrail"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:cloudtrail:${var.management_account_id}:${data.aws_caller_identity.current.id}:trail/goldrockCloudTrail"
      ]
    }
  }

  statement {
    sid = "configserviceencrypt"
    principals {
      type = "Service"
      identifiers = [
        "config.amzonaws.com"
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
      variable = "aws:SourceOrgID"
      values = [
        "${data.aws_organizations_organization.current.id}"
      ]
    }

  }

  statement {
    sid = "read"
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
        "s3.${data.aws_region.current.id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.id}"]
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
  description                        = "kms key for goldrock"
  deletion_window_in_days            = 30
  key_usage                          = "ENCRYPT_DECRYPT"
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  bypass_policy_lockout_safety_check = false
  is_enabled                         = true
  enable_key_rotation                = true
  multi_region                       = true
  policy                             = data.aws_iam_policy_document.keypolicy.json
}

resource "aws_kms_alias" "alias" {
  name          = "alias/goldrock-security"
  target_key_id = aws_kms_key.key.key_id
}