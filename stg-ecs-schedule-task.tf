resource "aws_cloudwatch_event_rule" "stg-summarize_daily_client_information" {
  name                  = "stg-summarize_daily_client_information"
  description           = "stg-summarize_daily_client_information"
  schedule_expression   = "cron(45 23 * * ? *)"
}
 
resource "aws_cloudwatch_event_target" "stg-summarize_daily_client_information" {
  target_id      = "stg-summarize_daily_client_information"
  arn            = aws_ecs_cluster.stg-matsuhub-ecs-api.arn
  rule           = aws_cloudwatch_event_rule.stg-summarize_daily_client_information.name
  role_arn       = aws_iam_role.ecs-scheduledtasks-role.arn
  input = jsonencode({
  "containerOverrides": [
    {
      "name": "stg-matsuhub-api",
      "command": ["bundle", "exec", "rake", "summarize_daily_client_information:run"]
    }
  ]
  })
  ecs_target {
    launch_type               = "FARGATE"
    task_count                = 1
    task_definition_arn       = aws_ecs_task_definition.stg-matsuhub-ecs-api.arn
    platform_version          = "LATEST"
    network_configuration {
      subnets = [
        aws_subnet.public-a.id,
        aws_subnet.public-c.id,
        aws_subnet.public-d.id
      ]

      security_groups = [
        aws_security_group.default_stg.id,
        aws_security_group.allow_api.id,
        aws_security_group.allow_all_outbound.id
      ]
      assign_public_ip        = true
    }
  }
}

# resource "aws_cloudwatch_event_rule" "stg-test-batch" {
#   name                  = "stg-test-batch"
#   description           = "stg-test-batch"
#   schedule_expression   = "cron(0/20 * * * ? *)"
# }

# resource "aws_cloudwatch_event_target" "stg-test-batch" {
#   target_id      = "stg-test-batch"
#   arn            = aws_ecs_cluster.stg-matsuhub-ecs-api.arn
#   rule           = aws_cloudwatch_event_rule.stg-test-batch.name
#   role_arn       = aws_iam_role.ecs-scheduledtasks-role.arn
#   input = jsonencode({
#   "containerOverrides": [
#     {
#       "name": "stg-matsuhub-api",
#       "command": ["bundle", "exec", "rake", "test_batch:run"]
#     }
#   ]
#   })
#   ecs_target {
#     launch_type               = "FARGATE"
#     task_count                = 1
#     task_definition_arn       = aws_ecs_task_definition.stg-matsuhub-ecs-api.arn
#     platform_version          = "LATEST"
#     network_configuration {
#       subnets = [
#         aws_subnet.public-a.id,
#         aws_subnet.public-c.id,
#         aws_subnet.public-d.id
#       ]

#       security_groups = [
#         aws_security_group.default_stg.id,
#         aws_security_group.allow_api.id,
#         aws_security_group.allow_all_outbound.id
#       ]
#       assign_public_ip        = true
#     }
#   }
# }