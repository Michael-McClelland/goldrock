resource "aws_iam_role" "goldrock_cloudtrail_management" {
  name = "goldrock-cloudtrail-management"

  assume_role_policy = data.aws_iam_policy_document.cloudtrail_management_trust_policy.json

  tags = {
    goldrock = "true"
  }
}
data "aws_iam_policy_document" "cloudtrail_management_trust_policy" {

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.partition.id}:iam::${module.organization_structure.security_account}:root"]
    }
    actions = [
      "sts:AssumeRole"
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
        module.organization_structure.security_account
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values = [
        "arn:${data.aws_partition.partition.id}:iam::${module.organization_structure.security_account}:role/goldrock-github-actions"
      ]
    }
  }
}

resource "aws_iam_policy" "goldrock_cloudtrail_management" {
  name        = "goldrock_cloudtrail_management"
  description = "goldrock cloudtrail management policy"
  policy      = data.aws_iam_policy_document.cloudtrail_management_policy.json
}

data "aws_iam_policy_document" "cloudtrail_management_policy" {

  statement {
    effect = "Allow"
    actions = [
      "cloudtrail:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "cloudtrail_management_policy" {
  name       = "cloudtrail_management_policy"
  roles      = [aws_iam_role.goldrock_cloudtrail_management.name]
  policy_arn = aws_iam_policy.goldrock_cloudtrail_management.arn
}

# resource "aws_iam_policy_attachment" "test-attach" {
#   name       = "view-only"
#   roles      = [aws_iam_role.goldrock_cloudtrail_management.name]
#   policy_arn = 
# }