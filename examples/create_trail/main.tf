provider "aws" {}

module "cloudtrail_watcher" {
  source = "rubysoho07/cloudtrail-watcher/aws"
  # Recommended to pin the module version
  # version = "0.0.2"

  slack_webhook_url = "https://hooks.slack.com/...."
  create_trail      = true
}
