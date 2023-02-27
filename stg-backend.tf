variable "stg_RDS_DB_NAME" {}
variable "stg_RDS_USERNAME" {}
variable "stg_RDS_PASSWORD" {}
variable "stg_RDS_HOSTNAME" {}
variable "stg_RDS_PORT" {} 
variable "stg_S3_RESOURCE_BUCKET" {}
variable "stg_MINIO_S3_ENDPOINT_URL_BY_RAILS" {}
variable "stg_API_HOST" {}
variable "stg_MAILER_SENDER" {}
variable "stg_RAILS_ENV" {}
variable "stg_API_DOMAIN" {}
variable "stg_SES_ACCESS_KEY_ID" {} 
variable "stg_SES_SECRET_ACCESS_KEY" {}
variable "stg_AWS_REGION" {}
variable "stg_RAILS_LOG_TO_STDOUT" {}
variable "stg_S3_AWS_ACCESS_KEY_ID" {}
variable "stg_S3_AWS_SECRET_ACCESS_KEY" {}
variable "stg_SENTRY_DSN" {}
variable "stg_CLOUDFRONT_DOMAIN" {}
variable "stg_RAILS_MASTER_KEY" {}

resource "aws_cloudwatch_log_group" "stg-matsuhub-ecs-api" {
      name = "stg-matsuhub-ecs-api"
}

resource "aws_lb" "stg-matsuhub-ecs-api" {
  name               = "stg-matsuhub-ecs-api"
  internal           = false
  enable_deletion_protection = false
  load_balancer_type = "application"

  subnets = [ 
    aws_subnet.public-a.id,
    aws_subnet.public-c.id,
    aws_subnet.public-d.id
  ]

  security_groups = [
    aws_security_group.default_stg.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id,
    aws_security_group.allow_api.id,
    aws_security_group.allow_all_outbound.id
  ]

}

resource "aws_alb_listener" "stg-matsuhub-ecs-api" {
  load_balancer_arn = aws_lb.stg-matsuhub-ecs-api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stg-matsuhub-ecs-api.arn
  }
}

resource "aws_ecs_task_definition" "stg-matsuhub-ecs-api" {
  family = "stg-matsuhub-ecs-api"

  # データプレーンの選択
  requires_compatibilities = ["FARGATE"]

  # ECSタスクが使用可能なリソースの上限
  # タスク内のコンテナはこの上限内に使用するリソースを収める必要があり、メモリが上限に達した場合OOM Killer にタスクがキルされる
  cpu    = "256"
  memory = "512"

  network_mode = "awsvpc"

  container_definitions = <<EOL
[
  {
    "name": "stg-matsuhub-api",
    "essential": true,
    "image": "${aws_ecr_repository.stg-matsuhub-api.repository_url}",
    "logConfiguration": {                                                                             
      "logDriver": "awslogs",                                                                         
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "stg-matsuhub-ecs-api",
        "awslogs-group": "stg-matsuhub-ecs-api"
      }
    },
    "secrets": [
      {
        "name": "RDS_HOSTNAME",
        "valueFrom": "${aws_ssm_parameter.stg_RDS_HOSTNAME.arn}"
      },
      {
        "name": "RDS_DB_NAME",
        "valueFrom": "${aws_ssm_parameter.stg_RDS_DB_NAME.arn}"
      },
      {
        "name": "RDS_PASSWORD",
        "valueFrom": "${aws_ssm_parameter.stg_RDS_PASSWORD.arn}"
      },
      {
        "name": "RDS_USERNAME",
        "valueFrom": "${aws_ssm_parameter.stg_RDS_USERNAME.arn}"
      },
      {
        "name": "RDS_PORT",
        "valueFrom": "${aws_ssm_parameter.stg_RDS_PORT.arn}"
      },
      {
        "name": "S3_RESOURCE_BUCKET",
        "valueFrom": "${aws_ssm_parameter.stg_S3_RESOURCE_BUCKET.arn}"
      },
      {
        "name": "MINIO_S3_ENDPOINT_URL_BY_RAILS",
        "valueFrom": "${aws_ssm_parameter.stg_MINIO_S3_ENDPOINT_URL_BY_RAILS.arn}"
      },
      {
        "name": "API_HOST",
        "valueFrom": "${aws_ssm_parameter.stg_API_HOST.arn}"
      },
      {
        "name": "MAILER_SENDER",
        "valueFrom": "${aws_ssm_parameter.stg_MAILER_SENDER.arn}"
      },
      {
        "name": "RAILS_ENV",
        "valueFrom": "${aws_ssm_parameter.stg_RAILS_ENV.arn}"
      },
      {
        "name": "API_DOMAIN",
        "valueFrom": "${aws_ssm_parameter.stg_API_DOMAIN.arn}"
      },
      {
        "name": "SES_ACCESS_KEY_ID",
        "valueFrom": "${aws_ssm_parameter.stg_SES_ACCESS_KEY_ID.arn}"
      },
      {
        "name": "SES_SECRET_ACCESS_KEY",
        "valueFrom": "${aws_ssm_parameter.stg_SES_SECRET_ACCESS_KEY.arn}"
      },
      {
        "name": "AWS_REGION",
        "valueFrom": "${aws_ssm_parameter.stg_AWS_REGION.arn}"
      },
      {
        "name": "RAILS_LOG_TO_STDOUT",
        "valueFrom": "${aws_ssm_parameter.stg_RAILS_LOG_TO_STDOUT.arn}"
      },
      {
        "name": "S3_AWS_ACCESS_KEY_ID",
        "valueFrom": "${aws_ssm_parameter.stg_S3_AWS_ACCESS_KEY_ID.arn}"
      },
      {
        "name": "S3_AWS_SECRET_ACCESS_KEY",
        "valueFrom": "${aws_ssm_parameter.stg_S3_AWS_SECRET_ACCESS_KEY.arn}"
      },
      {
        "name": "SENTRY_DSN",
        "valueFrom": "${aws_ssm_parameter.stg_SENTRY_DSN.arn}"
      },
      {
        "name": "CLOUDFRONT_DOMAIN",
        "valueFrom": "${aws_ssm_parameter.stg_CLOUDFRONT_DOMAIN.arn}"
      },
      {
        "name": "RAILS_MASTER_KEY",
        "valueFrom": "${aws_ssm_parameter.stg_RAILS_MASTER_KEY.arn}"
      }
    ],
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ]
  }
]
EOL

  task_role_arn= aws_iam_role.ecs-task-execution.arn
  execution_role_arn=aws_iam_role.ecs-task-execution.arn
}

resource "aws_ecs_cluster" "stg-matsuhub-ecs-api" {
  name = "stg-matsuhub-ecs-api"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.execute_command_audit.id
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.execute_command_audit.name
      }
    }
  }
}

resource "aws_lb_target_group" "stg-matsuhub-ecs-api" {
  name = "stg-matsuhub-ecs-api"
  depends_on = [
    aws_lb.stg-matsuhub-ecs-api
  ]

  # ターゲットグループを作成するVPC
  vpc_id = "${aws_vpc.Default_VPC.id}"

  # ALBからECSタスクのコンテナへトラフィックを振り分ける設定
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  # コンテナへの死活監視設定
  health_check {
    port = 8080
    path = "/health_check"
  }
  stickiness {
    enabled  = "true"
    type = "lb_cookie"
  }
}

resource "aws_appautoscaling_target" "stg-api" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.stg-matsuhub-ecs-api.name}/${aws_ecs_service.stg-matsuhub-ecs-api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_alb_listener_rule" "stg-matsuhub-ecs-api" {
  # ルールを追加するリスナー
  listener_arn = "${aws_alb_listener.stg-matsuhub-ecs-api.arn}"

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.stg-matsuhub-ecs-api.id}"
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_ecs_service" "stg-matsuhub-ecs-api" {
  name = "stg-matsuhub-ecs-api"

  # 依存関係の記述。
  # "aws_lb_listener_rule.main" リソースの作成が完了するのを待ってから当該リソースの作成を開始する。
  # "depends_on" は "aws_ecs_service" リソース専用のプロパティではなく、Terraformのシンタックスのため他の"resource"でも使用可能

  # 当該ECSサービスを配置するECSクラスターの指定
  cluster = aws_ecs_cluster.stg-matsuhub-ecs-api.name

  # データプレーンとしてFargateを使用する
  launch_type = "FARGATE"

  # ECSタスクの起動数を定義
  desired_count = "1"

  # 起動するECSタスクのタスク定義
  task_definition = aws_ecs_task_definition.stg-matsuhub-ecs-api.arn

  # ECSタスクへ設定するネットワークの設定
  network_configuration  {
    subnets = [
      aws_subnet.public-a.id,
      aws_subnet.public-c.id,
      aws_subnet.public-d.id
    ]

    # タスクに紐付けるセキュリティグループ
    security_groups = [
      aws_security_group.default_stg.id,
      aws_security_group.allow_http.id,
      aws_security_group.allow_api.id,
      aws_security_group.allow_all_outbound.id
    ]
    assign_public_ip = true
  }

  # ECSタスクの起動後に紐付けるELBターゲットグループ
  load_balancer {
      target_group_arn = aws_lb_target_group.stg-matsuhub-ecs-api.arn
      container_name   = aws_ecr_repository.stg-matsuhub-api.name
      container_port   = "8080"
  }
#  lifecycle {
#    ignore_changes = [
#      desired_count,
#      task_definition,
#    ]
#  }
  deployment_controller {
    type = "ECS"
  }

  enable_execute_command = true
  
}
resource "aws_route53_record" "stg-api" {
  type = "A"
  name    = "stg-api.${var.s3_zone_domain}"
  zone_id = "${var.s3_zone_id}"

  alias  {
    name    = aws_lb.stg-matsuhub-ecs-api.dns_name
    zone_id = aws_lb.stg-matsuhub-ecs-api.zone_id
    evaluate_target_health = true
  }
}  

## ECR 
locals {
  ecr-lifecycle-policy = {
    rules = [
      {
        action = {
          type = "expire"
        }
        description  = "最新のイメージを5つだけ残す"
        rulePriority = 1
        selection = {
          countNumber = 5
          countType   = "imageCountMoreThan"
          tagStatus   = "any"
        }
      },
    ]
  }
}

resource "aws_ecr_repository" "stg-matsuhub-api" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "stg-matsuhub-api"
}


# smm
resource "aws_ssm_parameter" "stg_RDS_DB_NAME" {
    name        = "stg_RDS_DB_NAME"
    description = "stg RDS_DB_NAME"
    type        = "SecureString"
    value       = var.stg_RDS_DB_NAME
}

resource "aws_ssm_parameter" "stg_RDS_USERNAME" {
    name        = "stg_RDS_USERNAME"
    description = "stg RDS_USERNAME"
    type        = "SecureString"
    value       = var.stg_RDS_USERNAME
}

resource "aws_ssm_parameter" "stg_RDS_PASSWORD" {
    name        = "stg_RDS_PASSWORD"
    description = "stg RDS_PASSWORD"
    type        = "SecureString"
    value       = var.stg_RDS_PASSWORD
}

resource "aws_ssm_parameter" "stg_RDS_HOSTNAME" {
    name        = "stg_RDS_HOSTNAME"
    description = "stg RDS_HOSTNAME"
    type        = "SecureString"
    value       = var.stg_RDS_HOSTNAME
}

resource "aws_ssm_parameter" "stg_RDS_PORT" {
    name        = "stg_RDS_PORT"
    description = "stg RDS_PORT"
    type        = "SecureString"
    value       = var.stg_RDS_PORT
}

resource "aws_ssm_parameter" "stg_S3_RESOURCE_BUCKET" {
    name        = "stg_S3_RESOURCE_BUCKET"
    description = "stg S3_RESOURCE_BUCKET"
    type        = "SecureString"
    value       = var.stg_S3_RESOURCE_BUCKET
}
resource "aws_ssm_parameter" "stg_MINIO_S3_ENDPOINT_URL_BY_RAILS" {
    name        = "stg_MINIO_S3_ENDPOINT_URL_BY_RAILS"
    description = "stg MINIO_S3_ENDPOINT_URL_BY_RAILS"
    type        = "SecureString"
    value       = var.stg_MINIO_S3_ENDPOINT_URL_BY_RAILS
}

resource "aws_ssm_parameter" "stg_API_HOST" {
    name        = "stg_API_HOST"
    description = "stg API_HOST"
    type        = "SecureString"
    value       = var.stg_API_HOST
}

resource "aws_ssm_parameter" "stg_MAILER_SENDER" {
    name        = "stg_MAILER_SENDER"
    description = "stg MAILER_SENDER"
    type        = "SecureString"
    value       = var.stg_MAILER_SENDER
}

resource "aws_ssm_parameter" "stg_RAILS_ENV" {
    name        = "stg_RAILS_ENV"
    description = "stg RAILS_ENV"
    type        = "SecureString"
    value       = var.stg_RAILS_ENV
}

resource "aws_ssm_parameter" "stg_API_DOMAIN" {
    name        = "stg_API_DOMAIN"
    description = "stg API_DOMAIN"
    type        = "SecureString"
    value       = var.stg_API_DOMAIN
    overwrite = true
}

resource "aws_ssm_parameter" "stg_SES_ACCESS_KEY_ID" {
    name        = "stg_SES_ACCESS_KEY_ID"
    description = "stg SES_ACCESS_KEY_ID"
    type        = "SecureString"
    value       = var.stg_SES_ACCESS_KEY_ID
}

resource "aws_ssm_parameter" "stg_SES_SECRET_ACCESS_KEY" {
    name        = "stg_SES_SECRET_ACCESS_KEY"
    description = "stg SES_SECRET_ACCESS_KEY"
    type        = "SecureString"
    value       = var.stg_SES_SECRET_ACCESS_KEY
}

resource "aws_ssm_parameter" "stg_AWS_REGION" {
    name        = "stg_AWS_REGION"
    description = "stg AWS_REGION"
    type        = "SecureString"
    value       = var.stg_AWS_REGION
}

resource "aws_ssm_parameter" "stg_RAILS_LOG_TO_STDOUT" {
    name        = "stg_RAILS_LOG_TO_STDOUT"
    description = "stg RAILS_LOG_TO_STDOUT"
    type        = "SecureString"
    value       = var.stg_RAILS_LOG_TO_STDOUT
}

resource "aws_ssm_parameter" "stg_S3_AWS_ACCESS_KEY_ID" {
    name        = "stg_S3_AWS_ACCESS_KEY_ID"
    description = "stg_S3_AWS_ACCESS_KEY_ID"
    type        = "SecureString"
    value       = var.stg_S3_AWS_ACCESS_KEY_ID
}
resource "aws_ssm_parameter" "stg_S3_AWS_SECRET_ACCESS_KEY" {
    name        = "stg_S3_AWS_SECRET_ACCESS_KEY"
    description = "stg_S3_AWS_SECRET_ACCESS_KEY"
    type        = "SecureString"
    value       = var.stg_S3_AWS_SECRET_ACCESS_KEY
}
resource "aws_ssm_parameter" "stg_SENTRY_DSN" {
    name        = "stg_SENTRY_DSN"
    description = "stg_SENTRY_DSN"
    type        = "SecureString"
    value       = var.stg_SENTRY_DSN
}
resource "aws_ssm_parameter" "stg_CLOUDFRONT_DOMAIN" {
    name        = "stg_CLOUDFRONT_DOMAIN"
    description = "stg_CLOUDFRONT_DOMAIN"
    type        = "SecureString"
    value       = var.stg_CLOUDFRONT_DOMAIN
}
resource "aws_ssm_parameter" "stg_RAILS_MASTER_KEY" {
    name        = "stg_RAILS_MASTER_KEY"
    description = "stg_RAILS_MASTER_KEY"
    type        = "SecureString"
    value       = var.stg_RAILS_MASTER_KEY
}

# ECS Execを実行するのに必要なIAMにアタッチするポリシードキュメント。不要かも
data "aws_iam_policy_document" "ecs_operation" {
  # ECS Execに必要なポリシー
  statement {
    effect = "Allow"
    actions = [
      "ecs:ExecuteCommand",
      "ecs:DescribeTasks",
      "kms:GenerateDataKey"
    ]
    resources = [
      aws_ecs_cluster.stg-matsuhub-ecs-api.arn,
      "arn:aws:ecs:${var.AWS_DEFAULT_REGION}:${var.AWS_ACCOUNT_ID}:task/${aws_ecs_cluster.stg-matsuhub-ecs-api.name}/*",
      aws_kms_key.execute_command_audit.arn
    ]
  }
  # ECS Execに必要なTask IDを取得するポリシー
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListTasks"
    ]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [aws_ecs_cluster.stg-matsuhub-ecs-api.arn]
    }
  }
}

data "aws_iam_policy_document" "execute_command_audit" {
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.AWS_ACCOUNT_ID}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.AWS_DEFAULT_REGION}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        # 循環参照を回避
        "arn:aws:logs:${var.AWS_DEFAULT_REGION}:${var.AWS_ACCOUNT_ID}:log-group:/ecs/stg-matsuhub-ecs-api/execute-command-audit"
      ]
    }
  }
}
resource "aws_kms_key" "execute_command_audit" {
  description              = "Master Key for stg-matsuhub-ecs-api ecs execute command audit log"
  is_enabled               = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  enable_key_rotation      = false
  deletion_window_in_days  = 30
  policy                   = data.aws_iam_policy_document.execute_command_audit.json

  tags = {
    Name = "stg-matsuhub-ecs-api execute-command-audit"
    Env  = "Staging"
  }
}

resource "aws_kms_alias" "execute_command_audit" {
  name          = "alias/stg-matsuhub-ecs-api-execute-command-audit"
  target_key_id = aws_kms_key.execute_command_audit.key_id

  depends_on = [aws_kms_key.execute_command_audit]
}

#
# CloudWatch Logs
#
resource "aws_cloudwatch_log_group" "execute_command_audit" {
  name = "/ecs/stg-matsuhub-ecs-api/execute-command-audit"

  retention_in_days = 365
  kms_key_id        = aws_kms_key.execute_command_audit.arn

  tags = {
    Name = "stg-matsuhub-ecs-api execute-command-audit"
  }
  depends_on = [aws_kms_key.execute_command_audit]
}