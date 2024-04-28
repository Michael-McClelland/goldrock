locals {
  organization = {
    # accounts = [
    #   {
    #     name  = "Default"
    #     key   = "goldrock-default"
    #     email = "root@company.com"
    #   }
    # ]
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
            # accounts = [
            #   {
            #     name  = "Blue"
            #     key   = "goldrock-myproduct-development-blue"
            #     email = "development@company.com"
            #   }
            # ]
          },
          {
            name = "teneble",
            key  = "goldrock-security-teneble"
            # accounts = [
            #   {
            #     name  = "Blue"
            #     key   = "goldrock-myproduct-production-blue"
            #     email = "production@company.com"
            #   }
            # ]
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
            # accounts = [
            #   {
            #     name  = "Blue"
            #     key   = "goldrock-myproduct-development-blue"
            #     email = "development@company.com"
            #   }
            # ]
          },
          {
            name = "testing",
            key  = "goldrock-infrastructure-testing"
            # accounts = [
            #   {
            #     name  = "Blue"
            #     key   = "goldrock-myproduct-production-blue"
            #     email = "production@company.com"
            #   }
            # ]
          },
          {
            name = "production",
            key  = "goldrock-infrastructure-production"
            # accounts = [
            #   {
            #     name  = "Blue"
            #     key   = "goldrock-myproduct-production-blue"
            #     email = "production@company.com"
            #   }
            # ]
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
}

module "organization_structure" {
  source = "./module"

  organization = local.organization
}

terraform {
  backend "s3" {
  }
}
