## Usage

### Basic Usage with New CloudTrail

```hcl
module "cloudtrail_watcher" {
  source = "rubysoho07/cloudtrail-watcher/aws"
  
  aws_region    = "us-east-1"
  create_trail  = true
  
  slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
}
```

### Usage with Existing CloudTrail

```hcl
module "cloudtrail_watcher" {
  source = "rubysoho07/cloudtrail-watcher/aws"
  
  aws_region        = "us-east-1"
  create_trail      = false
  trail_bucket_name = "your-existing-cloudtrail-bucket"
  
  slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
}
```