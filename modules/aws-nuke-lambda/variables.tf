variable "aws_nuke_lambda_function_role" {}
variable "aws_nuke_lambda_function_timeout" {}
variable "aws_nuke_lambda_function_memory_size" {}
variable "aws_nuke_lambda_function_name" {}
variable "aws_nuke_lambda_function_runtime" {}
variable "aws_nuke_lambda_function_tags" {}
variable "aws_nuke_lambda_function_env_vars" {
  type    = map(any)
  default = {}
}
