# terraform-aws-spend-controller
The terraform code (and Lambda Function code) within this repository is intended to be used to give you more control around your spending within your AWS Account.

I designed this automation to utilise resources that come at a free/very low-cost i.e. utilising free tier allowances for services such as AWS Budgets, AWS SNS and AWS Lambda Functions. Please familiarise yourself with the free-tier before deploying this stack within your AWS account.

The automation can be used for either;
- JUST notifying you about a upcoming/actually breached spend against a budget threshold that you set.
- Notifying you about a upcoming/actually breached spend against a budget threshold that you set AND running our AWS Nuke Lambda Function to destroy/remove resources that generally come at a high cost.

The ideal use-case for this stack would be in a personal AWS account where you're trying to avoid spending large amounts of money OR in some form of Sandbox/Testing account where you only want to spend a set amount during a specific period of time.

Please take the time to understand the code and the resource's that are created and USE AT YOUR OWN RISK! When writing this automation/stack/code (however you want to refer to it), I also wrote a medium article which hopefully gives more insight into everything: https://medium.com/@mark.southworth98/saving-money-and-staying-secure-whilst-utilising-aws-2b7b0167e759

## What Is Included In The Resources We Destroy With Our Lambda Function?
As listed in main.py, within our Lambda Function's source code, the following resource types are destroyed when we are utilising our full end-to-end automation (when we have enabled our destroy).

```
    _strategy = {
        "ami": NukeAmi,
        "ebs": NukeEbs,
        "snapshot": NukeSnapshot,
        "ec2": NukeEc2,
        "spot": NukeSpot,
        "endpoint": NukeEndpoint,
        "ecr": NukeEcr,
        "emr": NukeEmr,
        "kafka": NukeKafka,
        "autoscaling": NukeAutoscaling,
        "dlm": NukeDlm,
        "eks": NukeEks,
        "elasticbeanstalk": NukeElasticbeanstalk,
        "elb": NukeElb,
        "dynamodb": NukeDynamodb,
        "elasticache": NukeElasticache,
        "rds": NukeRds,
        "redshift": NukeRedshift,
        "cloudwatch": NukeCloudwatch,
        "efs": NukeEfs,
        "glacier": NukeGlacier,
        "s3": NukeS3,
    }

    _strategy_with_no_date = {
        "eip": NukeEip,
        "key_pair": NukeKeypair,
        "security_group": NukeSecurityGroup,
        "network_acl": NukeNetworkAcl,
    }
```
## How To Exclude Resources From A AWS Nuke Destroy (When We Have End-To-End Automation Enabled)
As shown within our main.tf input values below, we can pass in environment variables to our Lambda Function.
In order to exclude resources from destruction, you can pass them in to the Lambda Function's environment variables, like shown in the example below, where we exclude the destruction of EC2 Key Pairs:
```
  aws_nuke_lambda_function_env_vars = {
    EXCLUDE_RESOURCES = "key_pair"
    AWS_REGIONS       = "eu-west-1,eu-west-2"
    OLDER_THAN        = "0d"
  }
```


## main.tf Input Values - Where The Majority Of The Magic Happens!

```
// Create SNS topic and SNS topic subscription to alert us via email if we spend our budgeted amount
module "sns_spend_limit_notifications" {
  source                          = "./modules/sns" (DON'T CHANGE)
  sns_topic_name                  = "spend-nothing-monthly-alerting"
  sns_subscription_protocol       = "email"
  sns_topic_subscription_endpoint = "email@emailprovider.com"
}

// Create SNS topic and SNS topic subscription to trigger our AWS Nuke Lambda Function if we spend our budgeted amount
module "sns_spend_limit_lambda_trigger" {
  count                           = var.do_enable_automatic_resource_destroy ? 1 : 0 (DON'T CHANGE)
  source                          = "./modules/sns" (DON'T CHANGE)
  sns_topic_name                  = "spend-nothing-monthly-lambda-trigger"
  sns_subscription_protocol       = "lambda"
  sns_topic_subscription_endpoint = module.aws-nuke-lambda[0].nuke-function-arn (DON'T CHANGE)
}

// Create our monthly spend budget limit
// Use our above created sns topic and subscription to alert us in our chosen way
module "budget_spend_limit" {
  source                                    = "./modules/budgets" (DON'T CHANGE)
  budget_name                               = "spend-nothing-monthly"
  budget_currency_unit                      = "USD"
  budget_limit_amount                       = "1"
  budget_notification_comparison_operator   = "GREATER_THAN"
  budget_notification_sns_topic_arns        = [module.sns_spend_limit_notifications.sns_topic_arn](DON'T CHANGE)
  budget_notification_threshold             = "99" // We can't set two notification thresholds the same for the same budget, so set at 99% for notifying us.
  budget_notification_threshold_type        = "PERCENTAGE"
  budget_notification_type                  = "ACTUAL"
  budget_time_unit                          = "MONTHLY"
  do_enable_automatic_resource_destroy      = var.do_enable_automatic_resource_destroy (DON'T CHANGE)
  // Only Required If do_enable_automatic_resource_destroy is true
  budget_lambda_trigger_comparison_operator = "GREATER_THAN"
  budget_lambda_trigger_notification_type   = "ACTUAL"
  budget_lambda_trigger_sns_topic_arns      = try([module.sns_spend_limit_lambda_trigger[0].sns_topic_arn],"") (DON'T CHANGE)
  budget_lambda_trigger_threshold           = "100" // We can't set two notification thresholds the same for the same budget, so set at 100% for triggering our Lambda Function.
  budget_lambda_trigger_threshold_type      = "PERCENTAGE"
}

// Create our Lambda Function (AWS Nuke) that will be used to destroy our resources
// when we are equal to our monthly budget allowance
module "aws-nuke-lambda" {
  count                                = var.do_enable_automatic_resource_destroy ? 1 : 0 (DON'T CHANGE)
  source                               = "./modules/aws-nuke-lambda" (DON'T CHANGE)
  aws_nuke_lambda_function_memory_size = "512" 
  aws_nuke_lambda_function_name        = "aws-nuke-lambda"
  aws_nuke_lambda_function_role        = aws_iam_role.aws-nuke-lambda-function-role[0].arn (DON'T CHANGE)
  aws_nuke_lambda_function_runtime     = "python3.7" (DON'T CHANGE)
  aws_nuke_lambda_function_timeout     = "900" (DON'T CHANGE)
  aws_nuke_lambda_function_tags        = null
  aws_nuke_lambda_function_env_vars = {
    EXCLUDE_RESOURCES = ""
    AWS_REGIONS       = "eu-west-1,eu-west-2"
    OLDER_THAN        = "0d"
  }
  depends_on = [aws_iam_role.aws-nuke-lambda-function-role[0]] (DON'T CHANGE)
}

```

## variables.tf Input Values - A Few Centralised Controls!
```
variable "aws_account" {
  default = "123456789123"
}

variable "aws_region" {
  default = "eu-west-1" // The region you want to deploy the stack in
}

variable "do_enable_automatic_resource_destroy" {
  default = true // The variable that controls our notification vs notification and destroy options! Set to true to enable full automation including our destroy of expensive resources
}
```

## providers.tf Input Values - A Few Centralised Controls!
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0" // The version I wrote this utilising and tested with, change at your own risk/requirement!
    }
  }
}

// THIS DEPENDS ON HOW YOU ARE RUNNING THE TERRAFORM PLAN/APPLY, PLEASE REFER TO https://registry.terraform.io/providers/hashicorp/aws/latest/docs IF YOU ARE UNSURE!
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```

## Connect With Me!
GitHub - https://github.com/MikeTangoSierra

Medium - https://medium.com/@mark.southworth98

Email -
Mark.southworth98@gmail.com


## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate (apply to your own AWS account and test the functionality works).

Please format your terraform code using terraform fmt (recursively as we have modules in subdirectories).

## License

[MIT](https://choosealicense.com/licenses/mit/)
