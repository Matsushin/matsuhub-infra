variable "stg_SLACK_WEBHOOK_URL" {}

# メール通知用SNSトピック作成
resource "aws_sns_topic" "notificate" {
  name = "stg-matsuhub-error-notification"
}

# ["hoge@gmail.com", "fuga@gmail.com"] のように配列で通知先emailを渡す
# resource "aws_sns_topic_subscription" "topic_email_subscription" {
#   for_each  = { for email in var.emails : email => email }
#   topic_arn = aws_sns_topic.notificate.arn
#   protocol  = "email"
#   endpoint  = each.value
# }

# エラーログをSNSにパブリッシュするLambda関数を固める
data "archive_file" "sns_publish_func" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/sns_publish.zip"
}

resource "aws_lambda_function" "sns_publish_func" {
  filename         = data.archive_file.sns_publish_func.output_path
  function_name    = "sns_publish"
  role             = aws_iam_role.lambda_sns_publish.arn
  handler          = "app_log_notificate.index.lambda_handler"
  source_code_hash = data.archive_file.sns_publish_func.output_base64sha256
  runtime          = "python3.9"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notificate.arn
      ALARM_SUBJECT = "【Error Notification】stg-matsuhub-ecs-api"
      WEB_HOOK_URL  = var.stg_SLACK_WEBHOOK_URL
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.sns_publish_func,
    aws_iam_role.lambda_sns_publish
  ]

}

# CloudwatchLogsからLogの実行を許可
resource "aws_lambda_permission" "log_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_publish_func.arn
  principal     = "logs.ap-northeast-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.stg-matsuhub-ecs-api.arn}:*"
}

# lambda関数のログ出力のためのCloudWatchLogsのロググループ
resource "aws_cloudwatch_log_group" "sns_publish_func" {
  name              = "/aws/lambda/stg-matsuhub-ecs-api/sns_publish"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "error_log_subscription" {
  name            = "error-log-subscription"
  log_group_name  = aws_cloudwatch_log_group.stg-matsuhub-ecs-api.id
  filter_pattern  = "\"[ERROR]\""
  destination_arn = aws_lambda_function.sns_publish_func.arn
}

resource "aws_iam_role" "lambda_sns_publish" {
  name = "lambda-publish-sns"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-publish-sns"
  role = aws_iam_role.lambda_sns_publish.id

  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "",
      "Action": [
        "SNS:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}