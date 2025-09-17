# CloudTrail Watcher Terraform Module

한국어 버전: [README.ko.md](./README.ko.md)

A Terraform module that monitors AWS CloudTrail logs and sends notifications when resource creation events occur. This module automatically processes CloudTrail logs stored in S3 and can send alerts via SNS and Slack when Console login and AWS API activities of resource creation are detected.

This module uses Lambda Layer deployed in Serverless Application Repository. 

* [Serverless Application Repository](https://serverlessrepo.aws.amazon.com/applications/us-east-1/256724228018/cloudtrail-watcher-lambda-layer)
* [Layer source](https://github.com/rubysoho07/cloudtrail-watcher)

## Features

- **CloudTrail log monitoring**: Automatically processes CloudTrail logs as they are written to S3
- **Lambda-based processing**: Uses AWS Lambda to analyze CloudTrail events efficiently
- **Multiple notification channels**: Supports both SNS topics and Slack webhooks for alerts
- **Flexible deployment**: Can create a new CloudTrail or work with existing trails
- **Resource tagging**: Optional automatic tagging of AWS resources (Automatically add `User` tag for resources)
- **AutoScaling integration**: Can disable alarms for AutoScaling-created resources

## Supported events & resources

(Only support events when a resource created)

* Console Login (Success/Failure)
* IAM (User, Group, Role, Policy, Instance Profile)
* EC2 (Instance, Security Group)
* RDS (Cluster, Instance)
* S3 (Bucket)
* ElastiCache (Redis, Memcached)
* EMR (Cluster)
* Lambda (Function)
* Redshift (Cluster)
* ECS (Cluster)
* EKS (Cluster)
* DocumentDB (Cluster, Instance)
* MSK(Managed Streaming for Apache Kafka) (Cluster)
* MWAA(Managed Workflow for Apache Airflow) (Environment)
* DynamoDB (Table)
* ELB (CLB, ALB, NLB, GLB)
* CloudFront (Distribution)
* ECR (Repository)

## Architecture

![Architecture](https://github.com/rubysoho07/cloudtrail-watcher/raw/main/cloudtrail-watcher-architecture.png)

The module creates:
- AWS Lambda function to process CloudTrail logs
- SNS topic for notifications
- IAM roles and policies for a Lambda Function
- S3 bucket notifications to trigger Lambda processing
- (Optional) CloudTrail for API logging
- (Optional) S3 bucket for CloudTrail log storage (with a lifecycle: delete objects after 365 days)

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_prefix | Prefix for resources related with CloudTrail Watcher (If not set, 'cloudtrailwatcher-<YOUR_ACCOUNT_ID>') | string | "" | no |
| slack_webhook_url | Slack Webhook URL (set "DISABLED" to disable) | string | "DISABLED" | no |
| set_mandatory_tag | Make 'User' tags when resources are created. If you want to enable this feature, set this variable "True" | string | "False" | no |
| disable_autoscaling_alarm | Ignore alarm for resources created by autoscaling. If you want to enable this feature, set this variable "True" | string | "False" | no |
| trail_bucket_name | S3 bucket name for existing CloudTrail (required if `create_trail = false`) | string | "DISABLED" | no |
| create_trail | Whether to create a new CloudTrail trail and S3 bucket | bool | false | no |

## Requirements

- Terraform >= 0.12
- AWS Provider >= 2.0.0

## Permissions

The module requires permissions to:
- Create and manage Lambda functions
- Create and manage S3 buckets and notifications
- Create and manage CloudTrail (if creating new trail)
- Create and manage SNS topics
- Create and manage IAM roles and policies

## License

This module is released under the MIT License.