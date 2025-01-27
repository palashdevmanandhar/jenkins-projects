resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
<<<<<<< HEAD
  provider            = aws.region1
=======
>>>>>>> 7bf7d7bc134047c541c195bd1eb99ef9206cbb52
  alarm_name          = "scale-up-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Scale up if CPU > 90% for 1 minutes"
  alarm_actions       = [aws_autoscaling_policy.prod_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_server_asg.name
  }
}


resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  provider            = aws.region1
  alarm_name          = "scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 600
  statistic           = "Average"
  threshold           = 33 # Trigger when CPU utilization is 75% or higher
  alarm_description   = "Alarm to scale down instances when CPU utilization goes down below 33%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_server_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.prod_scale_down.arn]
}