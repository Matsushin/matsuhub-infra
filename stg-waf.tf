resource "aws_wafv2_web_acl" "stg-matsuhub-ecs-front" {
  name  = "stg-matsuhub-ecs-front"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["JP"]
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "stg-matsuhub-ecs-front-rate-limit"
      sampled_requests_enabled   = true
    }
  }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-stg-matsuhub-ecs-front"
      sampled_requests_enabled   = false
    }
}

resource "aws_wafv2_web_acl_association" "stg-matsuhub-ecs-front" {
  resource_arn = aws_lb.stg-matsuhub-ecs-front.arn
  web_acl_arn  = aws_wafv2_web_acl.stg-matsuhub-ecs-front.arn
}
