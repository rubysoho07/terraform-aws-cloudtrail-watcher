variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region to deploy CloudTrail Watcher"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resources related with CloudTrail Watcher"
  default     = ""

  validation {
    condition     = can(regex("^(|[a-z0-9\\-]+)$", var.resource_prefix))
    error_message = "Default prefix for resources MUST be blank or contain lowercase letters, hyphens, numbers."
  }
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack Webhook URL (If you don't want to use the feature, set DISABLED)"
  default     = "DISABLED"

  validation {
    condition     = can(regex("^(DISABLED|https://hooks.slack.com/services/[a-zA-Z/0-9]+)$", var.slack_webhook_url))
    error_message = "If you disable Slack notification, set this value DISABLED."
  }
}

variable "set_mandatory_tag" {
  type        = string
  description = "Set mandatory tags when resources are created."
  default     = "False"
}

variable "disable_autoscaling_alarm" {
  type        = string
  description = "Disable alarm for resources created by autoscaling"
  default     = "False"
}

variable "trail_bucket_name" {
  type        = string
  description = "The name of the S3 bucket used by CloudTrail to store log files."
  default     = "DISABLED"
}

variable "create_trail" {
  type        = bool
  default     = false
  description = "Whether to create a new CloudTrail trail. If false, you must set trail_bucket_name variable."
}
