resource "aws_ec2_allowed_images_settings" "aws_ec2_allowed_images_settings" {
  state = "enabled"

  image_criterion {
    image_providers = ["amazon"]

    creation_date_condition {
      maximum_days_since_created = 700
    }

    deprecation_time_condition {
        maximum_days_since_deprecated = 0
    }
  }
}