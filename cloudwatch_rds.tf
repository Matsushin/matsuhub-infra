resource "aws_cloudwatch_metric_alarm" "crit_RDS_CPUUtilization" {
  alarm_name                = "crit_RDS_CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors RDS cpu utilization average"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_DatabaseConnections" {
  alarm_name                = "crit_RDS_DatabaseConnections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "DatabaseConnections"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "500"
  alarm_description         = "This metric monitors RDS DatabaseConnections sum"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_FreeStorageSpace" {
  alarm_name                = "crit_RDS_FreeStorageSpace"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "500000000"
  alarm_description         = "This metric monitors RDS FreeStorageSpace average"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_WriteLatency" {
  alarm_name                = "crit_RDS_WriteLatency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "WriteLatency"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors RDS FreeStorageSpace average"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_ReadLatency" {
  alarm_name                = "crit_RDS_ReadLatency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "ReadLatency"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors RDS ReadLatency average"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_ReadThroughput" {
  alarm_name                = "crit_RDS_ReadThroughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "ReadLatency"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1000"
  alarm_description         = "This metric monitors RDS ReadThroughput average"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_WriteThroughput" {
  alarm_name                = "crit_RDS_WriteThroughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "WriteLatency"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1000"
  alarm_description         = "This metric monitors RDS WriteThroughput average"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_WriteIOPS" {
  alarm_name                = "crit_RDS_WriteIOPS"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "WriteIOPS"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1000"
  alarm_description         = "This metric monitors RDS WriteIOPS average"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_RDS_ReadIOPS" {
  alarm_name                = "crit_RDS_ReadIOPS"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "ReadIOPS"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1000"
  alarm_description         = "This metric monitors RDS ReadIOPS average"
  insufficient_data_actions = []
}
