resource "aws_accessanalyzer_analyzer" "aws_accessanalyzer_analyzer" {
  analyzer_name = "account"
}
terraform {
  backend "s3" {
  }
}