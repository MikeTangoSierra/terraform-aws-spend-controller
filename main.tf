########################################################################################################
# BUDGET & ALERTING VIA SNS
########################################################################################################

// Create SNS topic and SNS topic subscription to alert us via email if we spend our budgeted amount
module "sns_spend_limit_notifications" {
  source                          = "./modules/sns"
  sns_topic_name                  = ""
  sns_subscription_protocol       = ""
  sns_topic_subscription_endpoint = ""
}

// Create SNS topic and SNS topic subscription to trigger our AWS Nuke Lambda Function if we spend our budgeted amount
module "sns_spend_limit_lambda_trigger" {
  source                          = "./modules/sns"
  sns_topic_name                  = ""
  sns_subscription_protocol       = ""
  sns_topic_subscription_endpoint = module.aws-nuke-lambda.nuke-function-arn
}

// Create our monthly spend budget limit
// Use our above created sns topic and subscription to alert us in our chosen way
module "budget_spend_limit" {
  source                                  = "./modules/budgets"
  budget_name                             = ""
  budget_currency_unit                    = ""
  budget_limit_amount                     = ""
  budget_notification_comparison_operator = ""
  budget_notification_sns_topic_arns      = [module.sns_spend_limit_notifications.sns_topic_arn]
  budget_notification_threshold           = "" // We can't set two notification thresholds the same for the same budget, so set at 99% for notifying us.
  budget_notification_threshold_type      = ""
  budget_notification_type                = ""
  budget_time_unit                        = ""
  do_enable_automatic_resource_destroy    = var.do_enable_automatic_resource_destroy
  // Only Required If do_enable_automatic_resource_destroy is true
  budget_lambda_trigger_comparison_operator = ""
  budget_lambda_trigger_notification_type   = ""
  budget_lambda_trigger_sns_topic_arns      = try([module.sns_spend_limit_lambda_trigger[0].sns_topic_arn], "")
  budget_lambda_trigger_threshold           = "" // We can't set two notification thresholds the same for the same budget, so set at 100% for triggering our Lambda Function.
  budget_lambda_trigger_threshold_type      = ""
}

########################################################################################################
# AWS NUKE LAMBDA FUNCTION (AWS NUKE: https://github.com/rebuy-de/aws-nuke) WITH THANKS TO https://github.com/diodonfrost FOR THE GUIDANCE ON GETTING AWS NUKE RUNNING IN A LAMBDA FUNCTION
# THE LAMBDA FUNCTION DOES NOT DELETE OUR BUDGETS, SNS, LAMBDA OR IAM Resources
########################################################################################################
// Create our Lambda Function (AWS Nuke) that will be used to destroy our resources
// when we are equal to our monthly budget allowance
module "aws-nuke-lambda" {
  source                               = "./modules/aws-nuke-lambda"
  aws_nuke_lambda_function_memory_size = ""
  aws_nuke_lambda_function_name        = ""
  aws_nuke_lambda_function_role        = aws_iam_role.aws-nuke-lambda-function-role[0].arn
  aws_nuke_lambda_function_runtime     = ""
  aws_nuke_lambda_function_timeout     = ""
  aws_nuke_lambda_function_tags        = null
  aws_nuke_lambda_function_env_vars = {
    EXCLUDE_RESOURCES = ""
    AWS_REGIONS       = ""
    OLDER_THAN        = ""
  }
  depends_on = [aws_iam_role.aws-nuke-lambda-function-role]
}