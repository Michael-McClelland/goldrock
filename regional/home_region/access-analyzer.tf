resource "aws_accessanalyzer_analyzer" "aws_accessanalyzer_analyzer" {
  analyzer_name = "account"
}

resource "aws_accessanalyzer_analyzer" "aws_accessanalyzer_analyzer_unused_access" {
  analyzer_name = "unused-access"
  type          = "ACCOUNT_UNUSED_ACCESS"
}