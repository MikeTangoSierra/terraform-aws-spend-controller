resource "aws_budgets_budget" "spend_limit" {
  name         = var.budget_name
  budget_type  = "COST"
  time_unit    = var.budget_time_unit
  limit_amount = var.budget_limit_amount
  limit_unit   = var.budget_currency_unit

  // I know repeating these notifications blocks doesn't stick to DRY - However, I decided as they're completely separate use-cases/used for completely different reasons, it's fine to define the block twice instead of handling dynamically or otherwise.
  // I may change this in future releases.

  // Configure our budget to notify an SNS topic based on conditions set in budget_notification_comparison_operator, budget_notification_threshold, budget_notification_threshold_type and budget_notification_type variables.
  // This notification will be used for alerting/notifying us about the budget based on our configured conditions.
  notification {
    comparison_operator       = var.budget_notification_comparison_operator
    threshold                 = var.budget_notification_threshold
    threshold_type            = var.budget_notification_threshold_type
    notification_type         = var.budget_notification_type
    subscriber_sns_topic_arns = var.budget_notification_sns_topic_arns
  }

  // Configure our budget to notify an SNS topic based on conditions set in budget_lambda_trigger_comparison_operator, budget_lambda_trigger_threshold, budget_lambda_trigger_threshold_type and budget_lambda_trigger_notification_type variables.
  // This notification will be used to trigger our AWS Nuke Lambda Function.
  dynamic "notification" {
    content {
      comparison_operator       = var.budget_lambda_trigger_comparison_operator
      threshold                 = var.budget_lambda_trigger_threshold
      threshold_type            = var.budget_lambda_trigger_threshold_type
      notification_type         = var.budget_lambda_trigger_notification_type
      subscriber_sns_topic_arns = var.budget_lambda_trigger_sns_topic_arns
    }
    for_each = var.do_enable_automatic_resource_destroy ? [1] : []
  }
}