# terraform-aws-spend-controller
## module budgets
This module is utilised for the creation of our AWS Budgets. The main driver for our entire stack/automation!

We utilise AWS Budgets as it's another service we can utilise the free-tier for. We're allowed to create up to two budgets within our AWS account for free. This stack, as configured 'out-of-the-box' will utilise ONE of those free budgets from your account's quota.

For more information, please refer to the AWS documentation: https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/

## Usage/Input Variables (Examples Based On Being A Module Used Within This Repository ONLY!)

```bash
module "budget_spend_limit" {
  source                                    = "./modules/budgets" (DONT CHANGE THIS!)
  budget_name                               = "spend-nothing-monthly"
  budget_currency_unit                      = "USD"
  budget_limit_amount                       = "1"
  budget_notification_comparison_operator   = "GREATER_THAN"
  budget_notification_sns_topic_arns        = [module.sns_spend_limit_notifications.sns_topic_arn](DONT CHANGE THIS!)
  budget_notification_threshold             = "99" // We cant set two notification thresholds the same for the same budget, so set at 99% for notifying us.
  budget_notification_threshold_type        = "PERCENTAGE"
  budget_notification_type                  = "ACTUAL"
  budget_time_unit                          = "MONTHLY"
  do_enable_automatic_resource_destroy      = var.do_enable_automatic_resource_destroy
  // ONLY REQUIRED IF the do_enable_automatic_resource_destroy VARIABLE VALUE IS true
  budget_lambda_trigger_comparison_operator = "GREATER_THAN"
  budget_lambda_trigger_notification_type   = "ACTUAL"
  budget_lambda_trigger_sns_topic_arns      = try([module.sns_spend_limit_lambda_trigger[0].sns_topic_arn],"") (DONT CHANGE THIS!)
  budget_lambda_trigger_threshold           = "100" // We cant set two notification thresholds the same for the same budget, so set at 100% for triggering our Lambda Function.
  budget_lambda_trigger_threshold_type      = "PERCENTAGE"
}
```