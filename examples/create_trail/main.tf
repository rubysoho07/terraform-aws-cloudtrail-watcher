provider "aws" {}

module "cloudtrail_watcher" {
  source = "rubysoho07/cloudtrail-watcher/aws"
  # Recommended to pin the module version
  # version = "0.0.1"

  slack_webhook_url = var.slack_webhook_url
  create_trail      = true
}
