locals {
  organization = yamldecode(file("${path.module}/../configuration/organization.yaml"))
}

resource "aws_organizations_organization" "organization" {
  aws_service_access_principals = [
    "access-analyzer.amazonaws.com",
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "detective.amazonaws.com",
    "fms.amazonaws.com",
    "guardduty.amazonaws.com",
    "iam.amazonaws.com",
    "inspector2.amazonaws.com",
    "ipam.amazonaws.com",
    "macie.amazonaws.com",
    "malware-protection.guardduty.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "ram.amazonaws.com",
    "securityhub.amazonaws.com",
    "securitylake.amazonaws.com",
    "servicecatalog.amazonaws.com",
    "ssm.amazonaws.com",
    "sso.amazonaws.com",
    "storage-lens.s3.amazonaws.com",
    "tagpolicies.tag.amazonaws.com"
  ]
  enabled_policy_types = [
    "AISERVICES_OPT_OUT_POLICY",
    "BACKUP_POLICY",
    "RESOURCE_CONTROL_POLICY",
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
  feature_set = "ALL"
  lifecycle {
    prevent_destroy = true
  }
}

resource "time_sleep" "organization_service_principal_activation" {
  depends_on      = [aws_organizations_organization.organization]
  create_duration = "5m"
}

module "organization_structure" {
  source = "./module"
  organization = local.organization
}


data "aws_iam_policy_document" "organizations_policy" {

  statement {
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Allow"
    actions = [
      "organizations:Describe*",
      "organizations:List*"
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
}

resource "aws_organizations_resource_policy" "aws_organizations_resource_policy" {
  content = data.aws_iam_policy_document.organizations_policy.json
}

terraform {
  backend "s3" {
  }
}
