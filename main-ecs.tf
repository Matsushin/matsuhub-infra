####################################################
# ECS IAM Role
####################################################

resource "aws_iam_role" "ecs-task-execution" {
  name               = "ecs-task-execution"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}

data "aws_iam_policy_document" "operation_ecs_task" {
  # 独自に付与したいポリシー
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = ["*"]
  }
  # SSMに必要なポリシー
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
    ]
    resources = ["*"]
  }
  # 監査ログの書き込みに必要なポリシー
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.execute_command_audit.arn}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task-execution" {
  role = aws_iam_role.ecs-task-execution.id

  policy = data.aws_iam_policy_document.operation_ecs_task.json
}

## ECS Scheduled Tasks
resource "aws_iam_role" "ecs-scheduledtasks-role" {
  name               = "ecs-scheduledtasks-role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-scheduledtasks-role" {
  role       = aws_iam_role.ecs-scheduledtasks-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.ecs-task-execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
