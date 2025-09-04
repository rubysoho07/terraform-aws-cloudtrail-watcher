provider "aws" {
  # Set the AWS region where CloudTrail logs are stored
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region to deploy CloudTrail Watcher"
}

module "cloudtrail_watcher" {
  source = "rubysoho07/cloudtrail-watcher/aws"
  # Recommended to pin the module version
  # version = "0.0.2"

  slack_webhook_url = "https://hooks.slack.com/...."
  trail_bucket_name = "your-existing-bucket-name"
}
