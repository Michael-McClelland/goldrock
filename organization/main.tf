locals {
  organization = {
    units = [
      {
        name = "security",
        key  = "goldrock-security"
        accounts = [
          {
            name  = "securityservices"
            key   = "goldrock-securityservices"
            email = "mccmcc+securityservices@amazon.com"
          }
        ]
        units = [
          {
            name = "forensics",
            key  = "goldrock-security-forensics"
          },
          {
            name = "teneble",
            key  = "goldrock-security-teneble"
          }
        ]
      },
      {
        name = "infrastructure",
        key  = "goldrock-infrastructure"
        units = [
          {
            name = "development",
            key  = "goldrock-infrastructure-development"
          },
          {
            name = "testing",
            key  = "goldrock-infrastructure-testing"
          },
          {
            name = "production",
            key  = "goldrock-infrastructure-production"
          }
        ]
      }
    ]
  }
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
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
  feature_set = "ALL"
  lifecycle {
    prevent_destroy = true
  }
}

module "organization_structure" {
  source = "./module"

  organization = local.organization
}


data "aws_iam_policy_document" "organizations_policy" {

    statement {
    sid = "organizational-read"
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
        data.aws_organizations_organization.current.id
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
