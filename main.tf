terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }
}

data "aws_caller_identity" "current_account" {}

data "aws_region" "current" {}

data "archive_file" "lambda_function" {
  type = "zip"
  source {
    filename = "${path.module}/index.py"
    content  = <<EOF
from cloudtrail_watcher.event_handler import handler

def watcher_handler(event, context):
    return handler(event, context)
EOF
  }
  output_path = "${path.module}/lambda_function.zip"
}

locals {
  resource_prefix = var.resource_prefix == "" ? "cloudtrailwatcher-${data.aws_caller_identity.current_account.account_id}" : var.resource_prefix
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "cloudtrail_watcher_layer" {
  name = "cloudtrail-watcher-layer"

  application_id   = "arn:aws:serverlessrepo:us-east-1:256724228018:applications/cloudtrail-watcher-lambda-layer"
  semantic_version = "0.1.0"

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
}

resource "aws_lambda_function" "watcher_function" {
  function_name = local.resource_prefix
  description   = "CloudTrail Watcher Function"
  role          = aws_iam_role.watcher_function_role.arn
  timeout       = 120
  memory_size   = 512
  runtime       = "python3.12"
  handler       = "index.watcher_handler"
  filename      = data.archive_file.lambda_function.output_path
  layers        = [aws_serverlessapplicationrepository_cloudformation_stack.cloudtrail_watcher_layer.outputs["WatcherLayerArn"]]
  environment {
    variables = {
      SNS_TOPIC_ARN             = aws_sns_topic.watcher_sns_topic.arn
      SLACK_WEBHOOK_URL         = var.slack_webhook_url
      SET_MANDATORY_TAG         = var.set_mandatory_tag
      DISABLE_AUTOSCALING_ALARM = var.disable_autoscaling_alarm
    }
  }
}

resource "aws_lambda_permission" "watcher_function_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watcher_function.function_name
  principal     = "s3.amazonaws.com"
}

resource "aws_s3_bucket" "watcher_logs_bucket" {
  count  = var.create_trail ? 1 : 0
  bucket = local.resource_prefix
}

resource "aws_s3_bucket_notification" "watcher_logs_bucket_notification" {
  bucket = var.create_trail ? aws_s3_bucket.watcher_logs_bucket[0].id : var.trail_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.watcher_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.watcher_function_permission]
}

resource "aws_s3_bucket_lifecycle_configuration" "watcher_logs_bucket_lifecycle" {
  count  = var.create_trail ? 1 : 0
  bucket = aws_s3_bucket.watcher_logs_bucket[0].id

  rule {
    id     = "DeleteLogAfter1Year"
    status = "Enabled"
    expiration {
      days = 365
    }

    filter {}
  }
}

resource "aws_s3_bucket_policy" "watcher_logs_bucket_policy" {
  count  = var.create_trail ? 1 : 0
  bucket = aws_s3_bucket.watcher_logs_bucket[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.watcher_logs_bucket[0].arn
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.watcher_logs_bucket[0].arn}/*"
      }
    ]
  })
}

resource "aws_cloudtrail" "watcher_trail" {
  count      = var.create_trail ? 1 : 0
  depends_on = [aws_s3_bucket_policy.watcher_logs_bucket_policy[0]]

  name                          = local.resource_prefix
  s3_bucket_name                = aws_s3_bucket.watcher_logs_bucket[0].id
  enable_logging                = true
  is_multi_region_trail         = true
  include_global_service_events = true

  event_selector {
    read_write_type = "WriteOnly"
  }
}

resource "aws_sns_topic" "watcher_sns_topic" {
  name = local.resource_prefix
}

resource "aws_iam_role" "watcher_function_role" {
  name        = "${local.resource_prefix}-role"
  description = "Role for CloudTrail Watcher Lambda function"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role" {
  role       = aws_iam_role.watcher_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_resource_policy" {
  role       = aws_iam_role.watcher_function_role.name
  policy_arn = aws_serverlessapplicationrepository_cloudformation_stack.cloudtrail_watcher_layer.outputs["WatcherFunctionPolicyArn"]
}

resource "aws_iam_role_policy" "watcher_function_policy" {
  name = "${local.resource_prefix}-policy"
  role = aws_iam_role.watcher_function_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = var.create_trail ? "${aws_s3_bucket.watcher_logs_bucket[0].arn}/*" : "arn:aws:s3:::${var.trail_bucket_name}/*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.watcher_sns_topic.arn
      }
    ]
  })
}
