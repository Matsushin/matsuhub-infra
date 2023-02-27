variable "GITHUB_PERSONAL_ACCESS_TOKEN" {}


resource "aws_codebuild_source_credential" "backend" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.GITHUB_PERSONAL_ACCESS_TOKEN
}

resource "aws_iam_user" "codecommit_execution" {
  name = "codecommit_execution"
  tags = {
    tag-key = "Terraform"
  }
}

resource "aws_codebuild_webhook" "stg-matsuhub-infra" {
  project_name = aws_codebuild_project.stg-matsuhub-infra.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "staging"
    }
  }
}

resource "aws_codebuild_webhook" "stg-matsuhub-front" {
  project_name = aws_codebuild_project.stg-matsuhub-front.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "staging"
    }
  }
}
resource "aws_codebuild_webhook" "stg-matsuhub-backend" {
  project_name = aws_codebuild_project.stg-matsuhub-backend.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "staging"
    }
  }
}

resource "aws_codebuild_project" "stg-matsuhub-infra" {
  name          = "stg-matsuhub-infra"
  description   = "stg-matsuhub-infra"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_execution.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
      type = "NO_CACHE"
  }
#  cache {
#    type     = "S3"
#    location = aws_s3_bucket.s3_private_log.bucket
#  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.AWS_ACCOUNT_ID
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.AWS_DEFAULT_REGION
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "stg"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "DOCKERHUB_USER"
      value = aws_ssm_parameter.DOCKERHUB_USER.arn
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "DOCKERHUB_PASS"
      value = aws_ssm_parameter.DOCKERHUB_PASS.arn
      type  = "SECRETS_MANAGER"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group/matsuhub-infra"
      stream_name = "log-stream/matsuhub-infra"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.s3_private_log.id}/build-log/matsuhub-infra"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/Matsushin/matsuhub-infra"

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "staging"


  tags = {
    Environment = "Staging"
  }
}
resource "aws_codebuild_project" "stg-matsuhub-front" {
  name          = "stg-matsuhub-front"
  description   = "stg-matsuhub-front"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild_execution.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
      type = "NO_CACHE"
  }
#  cache {
#    type     = "S3"
#    location = aws_s3_bucket.s3_private_log.bucket
#  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.AWS_ACCOUNT_ID
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.AWS_DEFAULT_REGION
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "stg-matsuhub-front"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group/stg-matsuhub-front"
      stream_name = "log-stream/stg-matsuhub-front"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.s3_private_log.id}/build-log/stg-matsuhub-front"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/Matsushin/matsuhub-front"

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "staging"


  tags = {
    Environment = "Staging"
  }
}
resource "aws_codebuild_project" "stg-matsuhub-backend" {
  name          = "stg-matsuhub-backend"
  description   = "stg-matsuhub-backend"
  build_timeout = "10"
  #service_role  = aws_iam_role.codepipeline_execution.arn
  service_role  = aws_iam_role.codebuild_execution.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
      type = "NO_CACHE"
  }
#  cache {
#    type     = "S3"
#    location = aws_s3_bucket.s3_private_log.bucket
#  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.AWS_ACCOUNT_ID
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.AWS_DEFAULT_REGION
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "stg-matsuhub-api"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.s3_private_log.id}/build-log/stg-matsuhub-backend"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/Matsushin/matsuhub-back"

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "staging"


  tags = {
    Environment = "Staging"
  }
}

#resource "aws_codepipeline" "stg-matsuhub-backend" {
#  name     = "stg-matsuhub-backend"
#  role_arn = aws_iam_role.codepipeline_execution.arn
#
#  artifact_store {
#    location = aws_s3_bucket.s3_private_log.bucket
#    type     = "S3"
#  }
#
#  stage {
#    name = "Source"
#    action {
#      name             = "Source"
#      category         = "Source"
#      owner            = "AWS"
#      provider         = "CodeCommit"
#      version          = 1
#      output_artifacts = ["source_output"]
#      configuration = {
#        RepositoryName       = aws_codecommit_repository.backend.repository_name
#        BranchName           = "main"
#        OutputArtifactFormat = "CODE_ZIP"
#      }
#    }
#  }
#  stage {
#    name = "Build"
#    action {
#      name             = "Build"
#      category         = "Build"
#      owner            = "AWS"
#      provider         = "CodeBuild"
#      version          = 1
#      input_artifacts  = ["source_output"]
#      output_artifacts = ["build_output"]
#
#      configuration = {
#        ProjectName = aws_codebuild_project.backend.id
#      }
#    }
#  }
#  stage {
#    name = "Deploy"
#    action {
#      name            = "Deploy"
#      category        = "Deploy"
#      owner           = "AWS"
#      provider        = "ECS"
#      version         = 1
#      input_artifacts = ["build_output"]
#      configuration = {
#        ClusterName = aws_ecs_cluster.stg-matsuhub-ecs-api.id
#        ServiceName = aws_ecs_service.stg-matsuhub-ecs-api.name
#      }
#    }
#  }
#}

## cloudwatch event rule
#resource "aws_cloudwatch_event_rule" "codepipeline_backend" {
#  name = "codepipeline_backend"
#
#  event_pattern = templatefile("./file/codepipeline_event_pattern.json", {
#    codecommit_arn : aws_codecommit_repository.backend.arn
#  })
#}
#
#resource "aws_cloudwatch_event_target" "codepipeline_backend" {
#  rule     = aws_cloudwatch_event_rule.codepipeline_backend.name
#  arn      = aws_codepipeline.backend.arn
#  role_arn = aws_iam_role.event_bridge_codepipeline.arn
#}
#
#
## iam
#
resource "aws_iam_role" "codebuild_execution" {
  name = "codebuild_execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_execution" {
  role = aws_iam_role.codebuild_execution.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "kms:Decrypt"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
         "ecr:BatchCheckLayerAvailability",
         "ecr:InitiateLayerUpload",
         "ecr:UploadLayerPart",
         "ecr:CompleteLayerUpload",
         "ecr:PutImage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.s3_private_log.arn}",
        "${aws_s3_bucket.s3_private_log.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "codepipeline_execution" {
  name               = "CodePipeLineEcecutionRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "codepipeline.amazonaws.com",
            "codebuild.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
    })
  inline_policy {
    name   = "codepipeline"
    policy = jsonencode({
 "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
    })
  }
}
#resource "aws_iam_role" "event_bridge_codepipeline" {
#  name               = "event-bridge-codepipeline-role"
#  assume_role_policy = data.aws_iam_policy_document.event_bridge_assume_role.json
#  inline_policy {
#    name   = "codepipeline"
#    policy = data.aws_iam_policy_document.event_bridge_codepipeline.json
#  }
#}
#
#data "aws_iam_policy_document" "event_bridge_assume_role" {
#  statement {
#    actions = ["sts:AssumeRole"]
#
#    principals {
#      type        = "Service"
#      identifiers = ["events.amazonaws.com"]
#    }
#  }
#}
#
#data "aws_iam_policy_document" "event_bridge_codepipeline" {
#  statement {
#    actions   = ["codepipeline:StartPipelineExecution"]
#    resources = ["${aws_codepipeline.backend.arn}"]
#  }
#}
