# CloudTrail Watcher Terraform Module

CloudTrail 로그를 모니터링 하여 리소스 생성 이벤트가 발생했을 때 알림을 보내는 모듈입니다. 이 모듈은 S3에 저장된 CloudTrail 로그를 자동으로 처리하여, 콘솔 로그인 및 리소스 생성 이벤트가 발생할 때 Slack 또는 SNS를 통하여 알림을 발송합니다.

이 모듈은 Serverless Application Repository에 배포된 Lambda Layer를 사용합니다. 

* [Serverless Application Repository](https://serverlessrepo.aws.amazon.com/applications/us-east-1/256724228018/cloudtrail-watcher-lambda-layer)
* [Layer 소스 코드](https://github.com/rubysoho07/cloudtrail-watcher)

## 주요 기능

- **CloudTrail 로그 모니터링**: S3에 CloudTrail 로그가 올라가면 자동으로 처리함
- **Lambda 함수 기반 처리**: CloudTrail events 를 분석하여 처리하기 위해 AWS Lambda 사용
- **여러 알림 채널 지원**: SNS Topic 및 Slack 웹훅 지원
- **유연한 배포**: 새로운 CloudTrail을 생성하거나, 기존에 설정된 CloudTrail과 함께 연동 가능
- **리소스 태깅**: 신규 리소스에 대해 자동으로 `User` 태그를 추가하도록 설정할 수 있음
- **Auto Scaling 알람 무시**: Auto Scaling이 생성한 리소스에 대해서는 알람을 해제할 수 있습니다.

## 지원하는 이벤트와 리소스

(아래 리소스가 생성된 경우만 지원함)

* 콘솔 로그인 (성공/실패)
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

## 아키텍처

![Architecture](https://github.com/rubysoho07/cloudtrail-watcher/raw/main/cloudtrail-watcher-architecture.png)

이 모듈이 생성하는 리소스는 다음과 같습니다.

- CloudTrail 로그를 처리하는 Lambda 함수
- 알림을 위한 SNS topic
- Lambda 함수 동작을 위함 IAM 역할과 정책
- Lambda 함수로 처리하기 위한 S3 bucket 알림 설정
- (옵션) API 로깅을 위한 CloudTrail 설정
- (옵션) CloudTrail 로그 저장을 위한 S3 버킷 (365일 후 로그 삭제)

## 변수

| 이름 | 설명 | 타입 | 기본값 | 필수 여부 |
|------|-------------|------|---------|----------|
| resource_prefix | CloudTrail Watcher와 관련된 리소스의 접두사 (설정하지 않으면, `cloudtrailwatcher-<YOUR_ACCOUNT_ID>`) | string | "" | no |
| slack_webhook_url | Slack 웹훅 URL (비활성화 할 경우 "DISABLED"로 설정) | string | "DISABLED" | no |
| set_mandatory_tag | 리소스가 생성될 때 `User` 태그를 붙임. (활성화 하려는 경우, "True" 로 설정) | string | "False" | no |
| disable_autoscaling_alarm | 오토 스케일링으로 생성한 리소스에 대해서는 알리지 않음. (활성화 하려는 경우, "True"로 설정) | string | "False" | no |
| trail_bucket_name | 이미 설정된 CloudTrail에 연결된 S3 버킷 이름 (`create_trail = false`인 경우 필수) | string | "DISABLED" | no |
| create_trail | 새로운 CloudTrail trail과 S3 버킷 생성 여부 | bool | false | no |

## 요구사항

- Terraform >= 0.12
- AWS Provider >= 2.0.0

## 권한

이 모듈을 설치할 때 필요한 권한은 다음과 같습니다.

- Lambda 함수 생성 및 관리
- S3 버킷 및 알람 생성 및 관리
- CloudTrail 생성 및 관리 (신규 trail 생성 시)
- SNS 토픽 생성 및 관리
- IAM 역할 및 정책 설정 및 관리

## 라이센스

이 모듈은 MIT License로 배포합니다.