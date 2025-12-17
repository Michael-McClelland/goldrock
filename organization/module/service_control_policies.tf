resource "aws_organizations_policy" "goldrock_full_access" {
  name        = "goldrock-full-access"
  description = "Full access to all AWS services except Ground Station and QLDB"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = [
          "groundstation:*",
          "qldb:*"
        ]
        Resource = "*"
      }
    ]
  })
}