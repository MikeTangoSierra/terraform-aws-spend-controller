# terraform-aws-spend-controller
## module sns
This module is utilised for the creation of our SNS topic/s and subscription/s to them.

Much like the rest of the overall stack, I believe that the average usage of SNS for the purpose/s it's being used for in this stack will work out to be free and if not, very low cost. Of course, this is dependant on your use-case and this comment is purely educational.

I'd recommend referring to the SNS pricing documentation for further information: https://aws.amazon.com/sns/pricing/

## Usage/Input Variables (Examples Based On Being A Module Used Within This Repository ONLY!) - Two example's are listed as per the module calls in main.tf

```bash
// Create SNS topic and SNS topic subscription to alert us via email if we spend our budgeted amount
module "sns_spend_limit_notifications" {
  source                          = "./modules/sns" (DONT CHANGE THIS!)
  sns_topic_name                  = "spend-nothing-monthly-alerting"
  sns_subscription_protocol       = "email" (DONT CHANGE THIS!)
  sns_topic_subscription_endpoint = "email@emailproviderdomain.com"
}

// Create SNS topic and SNS topic subscription to trigger our AWS Nuke Lambda Function if we spend our budgeted amount
module "sns_spend_limit_lambda_trigger" {
  count                           = var.do_enable_automatic_resource_destroy ? 1 : 0 (DONT CHANGE THIS!)
  source                          = "./modules/sns" (DONT CHANGE THIS!)
  sns_topic_name                  = "spend-nothing-monthly-lambda-trigger"
  sns_subscription_protocol       = "lambda" (DONT CHANGE THIS!)
  sns_topic_subscription_endpoint = module.aws-nuke-lambda[0].nuke-function-arn (DONT CHANGE THIS!)
}
```