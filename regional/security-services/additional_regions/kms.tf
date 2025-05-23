data "aws_iam_policy_document" "keypolicy" {
  
  statement {
    sid = "configserviceencrypt"
    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com"
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
        aws_s3_bucket.config.arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        "${data.aws_organizations_organization.organization.id}"
      ]
    }

  }

  statement {
    sid = "config-decrypt"
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
        aws_s3_bucket.config.arn
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

#Terraform DataCall Management Account
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]

    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.organization.id
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values = [
        data.aws_organizations_organization.organization.master_account_id
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_organizations_organization.organization.master_account_id}:role/goldrock-cloudtrail-management"
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

resource "aws_kms_replica_key" "key" {
  description                        = "kms key for goldrock"
  deletion_window_in_days            = 30
  bypass_policy_lockout_safety_check = false
  policy                             = data.aws_iam_policy_document.keypolicy.json
  primary_key_arn = var.home_region_cmk_arn
}

resource "aws_kms_alias" "alias" {
  name          = "alias/goldrock-security"
  target_key_id = aws_kms_replica_key.key.key_id
}