# terraform-aws-spend-controller
## module aws-nuke-lambda

This module is utilised for the creation of our Lambda Function that utilises AWS Nuke to destroy costly AWS Resources. We will stick to our theme and utilise free-tier here (depending on how often you run the Lambda Function!)

You can read more about AWS Nuke in their own GitHub repositories README.md, which can be found in AWS Nuke's repository:  https://github.com/rebuy-de/aws-nuke

You can read more about AWS Lambda Functions here: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
You can read more about AWS Lambda Functions pricing here: https://docs.aws.amazon.com/whitepapers/latest/how-aws-pricing-works/lambda.html

## Enabling The Module

The module is 'enabled' i.e. module called and resources created in variables.tf of the main terraform implementation variables (variables.tf in the root directory of the repository).

The value of do_enable_automatic_resource_destroy must be set to true.

```bash
variable "do_enable_automatic_resource_destroy" {
  default = true
}
```

## Usage/Input Variables (Examples Based On Being A Module Used Within This Repository ONLY!)

```bash
module "aws-nuke-lambda" {
  count                                = var.do_enable_automatic_resource_destroy ? 1 : 0
  source                               = "./modules/aws-nuke-lambda"
  aws_nuke_lambda_function_memory_size = "512"
  aws_nuke_lambda_function_name        = "aws-nuke-lambda"
  aws_nuke_lambda_function_role        = aws_iam_role.aws-nuke-lambda-function-role[0].arn
  aws_nuke_lambda_function_runtime     = "python3.7"
  aws_nuke_lambda_function_timeout     = "900"
  aws_nuke_lambda_function_tags        = null
  aws_nuke_lambda_function_env_vars = {
    EXCLUDE_RESOURCES = ""
    AWS_REGIONS       = "eu-west-1,eu-west-2"
    OLDER_THAN        = "0d"
  }
  depends_on = [aws_iam_role.aws-nuke-lambda-function-role[0]]
}
```

## A Special Thanks

During the time I spent creating this module, I utilised some previous work from @diodonfrost https://github.com/diodonfrost as a form of guidance to implementing AWS Nuke inside a Lambda Function (other examples listed in AWS Nuke's README.md were, at the time of writing, limited to running AWS Nuke in a more stateful manner (i.e. on a Linux Server for example).