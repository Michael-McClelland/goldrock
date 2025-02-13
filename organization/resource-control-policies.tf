data "aws_iam_policy_document" "resource_control_standard_policy" {

  statement {
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

  statement {
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }

  # statement {
  #   principals {
  #     type = "AWS"
  #     identifiers = [
  #       "*"
  #     ]
  #   }
  #   effect = "Deny"
  #   actions = [

  #     "s3:*",
  #   ]
  #   resources = [
  #     "*",
  #   ]
  #   condition {
  #     test     = "Null"
  #     variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
  #     values = [
  #       "true"
  #     ]
  #   }
  # }

  statement {
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Deny"
    actions = [
      "kms:*",
      "s3:*",
      "secretsmanager:*",
      "sqs:*",
      "sts:*",
    ]
    resources = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }

  # statement {
  #   principals {
  #     type = "AWS"
  #     identifiers = [
  #       "*"
  #     ]
  #   }
  #   effect = "Deny"
  #   actions = [
  #     "s3:*",
  #     "secretsmanager:*",
  #     "sqs:*",
  #   ]
  #   resources = [
  #     "*",
  #   ]
  #   condition {
  #     test     = "StringNotEqualsIfExists"
  #     variable = "aws:SourceOrgID"
  #     values = [
  #       data.aws_organizations_organization.organization.id
  #     ]
  #   }
  #   condition {
  #     test     = "Bool"
  #     variable = "aws:PrincipalIsAWSService"
  #     values = [
  #       "true"
  #     ]
  #   }
  #   condition {
  #     test     = "Null"
  #     variable = "aws:SourceAccount"
  #     values = [
  #       "false"
  #     ]
  #   }
  # }
}

resource "aws_organizations_policy" "resource_control_standard_policy" {

  depends_on = [ aws_organizations_organization.organization ]
  name    = "resource-control-standard-policy"
  type = "RESOURCE_CONTROL_POLICY"
  content = data.aws_iam_policy_document.resource_control_standard_policy.json
}

resource "aws_organizations_policy_attachment" "resource_control_standard_policy" {
  policy_id = aws_organizations_policy.resource_control_standard_policy.id
  target_id = data.aws_organizations_organization.organization.roots[0].id
}

