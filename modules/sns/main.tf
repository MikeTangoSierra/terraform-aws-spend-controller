resource "aws_sns_topic" "topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = var.sns_subscription_protocol
  endpoint  = var.sns_topic_subscription_endpoint
}