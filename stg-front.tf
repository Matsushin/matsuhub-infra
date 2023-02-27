variable "stg_NEXT_PUBLIC_RESTAPI_URL" {}
variable "stg_NEXT_PUBLIC_USER" {}
variable "stg_NEXT_PUBLIC_PASS" {}

resource "aws_cloudwatch_log_group" "stg-matsuhub-ecs-front" {
  name = "stg-matsuhub-ecs-front"
  retention_in_days = 30
}

resource "aws_lb" "stg-matsuhub-ecs-front" {
  name               = "stg-matsuhub-ecs-front"
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

  access_logs {
    bucket  = aws_s3_bucket.s3_private_log.bucket
    prefix  = "logs"
    enabled = true
  }
}

resource "aws_alb_listener" "stg-matsuhub-ecs-front" {
  load_balancer_arn = aws_lb.stg-matsuhub-ecs-front.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stg-matsuhub-ecs-front.arn
  }
}



resource "aws_ecs_task_definition" "stg-matsuhub-ecs-front" {
  family = "stg-matsuhub-ecs-front"

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
    "name": "stg-matsuhub-front",
    "essential": true,
    "image": "${aws_ecr_repository.stg-matsuhub-front.repository_url}",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "stg-matsuhub-ecs-front",
        "awslogs-group": "stg-matsuhub-ecs-front"
      }
    },
    "secrets": [
      {
        "name": "NEXT_PUBLIC_RESTAPI_URL",
        "valueFrom": "${aws_ssm_parameter.stg_NEXT_PUBLIC_RESTAPI_URL.arn}"
      }
    ],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOL
# Facebook app 
#  container_definitions = <<EOL
#[
#  {
#    "name": "stg-front",
#    "essential": true,
#    "image": "${aws_ecr_repository.stg-matsuhub-front.repository_url}",
#    "secrets": [
#      {
#        "name": "NEXT_PUBLIC_RESTAPI_URL",
#        "valueFrom": "${aws_ssm_parameter.stg_NEXT_PUBLIC_RESTAPI_URL.arn}"
#      },
#      {
#        "name": "FACEBOOK_APP_ID",
#        "valueFrom": "${aws_ssm_parameter.stg_FACEBOOK_APP_ID.arn}"
#      },
#      {
#        "name": "NEXT_PUBLIC_USER",
#        "valueFrom": "${aws_ssm_parameter.stg_NEXT_PUBLIC_USER.arn}"
#      },
#      {
#        "name": "NEXT_PUBLIC_PASS",
#        "valueFrom": "${aws_ssm_parameter.stg_NEXT_PUBLIC_PASS.arn}"
#      }
#    ],
#    "portMappings": [
#      {
#        "containerPort": 80,
#        "hostPort": 80
#      }
#    ]
#  }
#]
#EOL

  task_role_arn= aws_iam_role.ecs-task-execution.arn
  execution_role_arn=aws_iam_role.ecs-task-execution.arn
}

# ECS Cluster
# https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
resource "aws_ecs_cluster" "stg-matsuhub-ecs-front" {
  name = "stg-matsuhub-ecs-front"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


# ELB Target Group
# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_lb_target_group" "stg-matsuhub-ecs-front" {
  name = "stg-matsuhub-ecs-front"
  depends_on = [
    aws_lb.stg-matsuhub-ecs-front
  ]

  # ターゲットグループを作成するVPC
  vpc_id = "${aws_vpc.Default_VPC.id}"

  # ALBからECSタスクのコンテナへトラフィックを振り分ける設定
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  # コンテナへの死活監視設定
  health_check {
    port = 80
    path = "/health_check"
  }
}

resource "aws_appautoscaling_target" "stg-front" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.stg-matsuhub-ecs-front.name}/${aws_ecs_service.stg-matsuhub-ecs-front.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ALB Listener Rule
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
resource "aws_alb_listener_rule" "stg-matsuhub-ecs-front-admin" {
  # ルールを追加するリスナー
  listener_arn = "${aws_alb_listener.stg-matsuhub-ecs-front.arn}"
  priority = 1

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.stg-matsuhub-ecs-front.id}"
  }
  condition {
    source_ip {
      values = var.admin_ips
    }
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
resource "aws_alb_listener_rule" "stg-matsuhub-ecs-front" {
  # ルールを追加するリスナー
  listener_arn = "${aws_alb_listener.stg-matsuhub-ecs-front.arn}"
  priority = 100

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.stg-matsuhub-ecs-front.id}"
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
resource "aws_alb_listener_rule" "stg-matsuhub-ecs-front-maintenance" {
  listener_arn = aws_alb_listener.stg-matsuhub-ecs-front.arn
  priority = var.stg-maintenance-priority

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = var.maintenance_body
      status_code  = "503"
    }
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
#resource "aws_alb_listener" "stg-matsuhub-ecs-front" {
#  load_balancer_arn = aws_lb.stg-matsuhub-ecs-front.arn
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = aws_acm_certificate.cert.arn
#
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.stg-matsuhub-ecs-front.arn
#  }
#}
#resource "aws_alb_listener" "stg-matsuhub-ecs-front-maintenance" {
#  load_balancer_arn = aws_lb.stg-matsuhub-ecs-front.arn
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = aws_acm_certificate.cert.arn
#
#  default_action {
#    type = "fixed-response"
#    fixed_response {
#      content_type = "text/html"
#      message_body = var.maintenance_body
#      status_code  = "503"
#    }
#  }
#}
# ECS Service
# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "stg-matsuhub-ecs-front" {
  name = "stg-matsuhub-ecs-front"

  # 依存関係の記述。
  # "aws_lb_listener_rule.main" リソースの作成が完了するのを待ってから当該リソースの作成を開始する。
  # "depends_on" は "aws_ecs_service" リソース専用のプロパティではなく、Terraformのシンタックスのため他の"resource"でも使用可能

  # 当該ECSサービスを配置するECSクラスターの指定
  cluster = aws_ecs_cluster.stg-matsuhub-ecs-front.name

  # データプレーンとしてFargateを使用する
  launch_type = "FARGATE"

  # ECSタスクの起動数を定義
  desired_count = "1"

  # 起動するECSタスクのタスク定義
  task_definition = aws_ecs_task_definition.stg-matsuhub-ecs-front.arn

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
      aws_security_group.allow_all_outbound.id
    ]
    assign_public_ip = true
  }

  # ECSタスクの起動後に紐付けるELBターゲットグループ
  load_balancer {
      target_group_arn = aws_lb_target_group.stg-matsuhub-ecs-front.arn
      container_name   = aws_ecr_repository.stg-matsuhub-front.name
      container_port   = "80"
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
  
}
resource "aws_route53_record" "stg-front" {
  type = "A"
  name    = "stg.${var.s3_zone_domain}"
  zone_id = "${var.s3_zone_id}"

  alias  {
    name    = aws_lb.stg-matsuhub-ecs-front.dns_name
    zone_id = aws_lb.stg-matsuhub-ecs-front.zone_id
    evaluate_target_health = true
  }
}  


## ECR 
resource "aws_ecr_repository" "stg-matsuhub-front" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "stg-matsuhub-front"
}


resource "aws_ecr_lifecycle_policy" "stg-front" {
  repository = aws_ecr_repository.stg-matsuhub-front.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}

# smm
resource "aws_ssm_parameter" "stg_NEXT_PUBLIC_RESTAPI_URL" {
    name        = "stg_NEXT_PUBLIC_RESTAPI_URL"
    description = "stg NEXT_PUBLIC_RESTAPI_URL"
    type        = "SecureString"
    value       = var.stg_NEXT_PUBLIC_RESTAPI_URL
}

resource "aws_ssm_parameter" "stg_NEXT_PUBLIC_USER" {
    name        = "stg_NEXT_PUBLIC_USER"
    description = "stg NEXT_PUBLIC_USER"
    type        = "SecureString"
    value       = var.stg_NEXT_PUBLIC_USER
}

resource "aws_ssm_parameter" "stg_NEXT_PUBLIC_PASS" {
    name        = "stg_NEXT_PUBLIC_PASS"
    description = "stg NEXT_PUBLIC_PASS"
    type        = "SecureString"
    value       = var.stg_NEXT_PUBLIC_PASS
}
