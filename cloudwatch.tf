resource "aws_cloudwatch_metric_alarm" "crit_CPUUtilization" {
  alarm_name                = "crit_CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_EBSWriteBytes" {
  alarm_name                = "crit_EBSWriteBytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "EBSWriteBytes"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "500000000"
  alarm_description         = "This metric monitors ec2 EBSWriteBytes"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_EBSReadBytes" {
  alarm_name                = "crit_EBSReadBytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "EBSReadBytes"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "500000000"
  alarm_description         = "This metric monitors ec2 crit_EBSReadBytes"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_NetworkIn" {
  alarm_name                = "crit_NetworkIn"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "NetworkIn"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "100000000"
  alarm_description         = "This metric monitors ec2 NetworkIn"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_NetworkOut" {
  alarm_name                = "crit_NetworkOut"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "NetworkOut"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "100000000"
  alarm_description         = "This metric monitors ec2 NetworkOut"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_NetworkPacketsIn" {
  alarm_name                = "crit_NetworkPacketsIn"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "NetworkPacketsIn"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "10000"
  alarm_description         = "This metric monitors ec2 NetworkPacketsIn"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "crit_NetworkPacketsOut" {
  alarm_name                = "crit_NetworkPacketsOut"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "NetworkPacketsOut"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "10000"
  alarm_description         = "This metric monitors ec2 NetworkPacketsOut"
  insufficient_data_actions = []
}
