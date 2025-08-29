# Terraform AWS CloudTrail Watcher

AWS 환경에서 발생하는 모든 API 활동을 모니터링하고, 특정 이벤트 발생 시 슬랙(Slack)으로 알림을 보내거나 리소스에 강제로 태그를 추가하는 Terraform 모듈입니다.

CloudTrail 로그를 S3에 저장하고, 새로운 로그 파일이 생성될 때마다 Lambda 함수를 트리거하여 로그를 분석하고 정의된 작업을 수행합니다.

## 주요 기능

*   **CloudTrail 설정**: 모든 리전의 쓰기(Write) 이벤트를 기록하는 CloudTrail Trail을 생성합니다.
*   **S3 버킷 생성**: CloudTrail 로그를 저장하기 위한 S3 버킷을 생성하고, 1년 후 로그가 자동으로 삭제되도록 라이프사이클 설정을 합니다.
*   **Lambda 함수**: CloudTrail 로그를 분석하여 다음 작업을 수행하는 Lambda 함수를 배포합니다.
    *   **슬랙 알림**: 특정 이벤트 발생 시 지정된 슬랙 웹훅 URL로 알림을 보냅니다.
    *   **강제 태그 추가**: 리소스 생성 이벤트 발생 시, 정의된 필수 태그(`Owner` 등)를 리소스에 자동으로 추가합니다.
*   **IAM 역할 및 정책**: Lambda 함수와 CloudTrail이 작동하는 데 필요한 최소한의 권한을 가진 IAM 역할과 정책을 생성합니다.
*   **SNS Topic**: 알림을 위한 SNS Topic을 생성합니다.

## 사용 예시

```hcl
module "cloudtrail_watcher" {
  source = "git::https://github.com/your-repo/terraform-aws-cloudtrail-watcher.git"

  aws_region        = "ap-northeast-2"
  resource_prefix   = "my-project-cloudtrail"
  slack_webhook_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
  set_mandatory_tag = "ENABLED"
  mandatory_tag_key = "Service"
  mandatory_tag_value = "MyWebApp"
}
```

## 입력 변수 (Inputs)

| 이름                        | 설명                                                                 | 타입   | 기본값      | 필수 여부 |
| --------------------------- | -------------------------------------------------------------------- | ------ | ----------- | --------- |
| `aws_region`                | 리소스를 배포할 AWS 리전입니다.                                      | `string` | `"us-east-1"` | 아니요    |
| `aws_profile`               | 사용할 AWS 프로필 이름입니다.                                        | `string` | `"default"`   | 아니요    |
| `resource_prefix`           | 생성될 리소스의 접두사입니다. 비워두면 `cloudtrailwatcher-<account_id>`가 사용됩니다. | `string` | `""`          | 아니요    |
| `slack_webhook_url`         | 슬랙 알림을 받을 웹훅 URL입니다. 비활성화하려면 `"DISABLED"`로 설정합니다. | `string` | `"DISABLED"`  | 아니요    |
| `set_mandatory_tag`         | 리소스 생성 시 강제 태그 추가 기능을 활성화합니다. (`"ENABLED"` / `"DISABLED"`) | `string` | `"DISABLED"`  | 아니요    |
| `disable_autoscaling_alarm` | 오토스케일링으로 생성된 리소스에 대한 알림을 비활성화합니다. (`"ENABLED"` / `"DISABLED"`) | `string` | `"DISABLED"`  | 아니요    |
| `mandatory_tag_key`         | 강제로 추가할 태그의 키(Key)입니다.                                  | `string` | `"Owner"`     | 아니요    |
| `mandatory_tag_value`       | 강제로 추가할 태그의 값(Value)입니다.                                | `string` | `"default"`   | 아니요    |

## 출력 (Outputs)

이 모듈은 현재 정의된 출력이 없습니다.

## 생성되는 리소스

이 모듈은 다음과 같은 AWS 리소스를 생성합니다.

*   `aws_cloudtrail`
*   `aws_s3_bucket`
*   `aws_s3_bucket_notification`
*   `aws_s3_bucket_lifecycle_configuration`
*   `aws_s3_bucket_policy`
*   `aws_lambda_function`
*   `aws_lambda_permission`
*   `aws_iam_role` (Lambda 실행용)
*   `aws_iam_role_policy`
*   `aws_iam_role_policy_attachment`
*   `aws_sns_topic`

## Lambda 함수

이 모듈은 Lambda 함수를 배포하지만, Lambda 함수의 소스 코드는 이 저장소에 포함되어 있지 않습니다. `aws_lambda_function` 리소스의 `handler`가 `lambda_function.handler`로 설정되어 있으므로, 배포 패키지에 `lambda_function.py` 파일이 포함되어 있어야 합니다.

## 라이선스

이 프로젝트는 Apache 2.0 라이선스를 따릅니다.
