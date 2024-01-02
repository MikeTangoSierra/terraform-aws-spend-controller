resource "aws_lambda_function" "nuke-function" {
  function_name = var.aws_nuke_lambda_function_name
  runtime       = var.aws_nuke_lambda_function_runtime
  filename      = data.archive_file.aws-nuke-zip.output_path
  timeout       = var.aws_nuke_lambda_function_timeout
  memory_size   = var.aws_nuke_lambda_function_memory_size
  role          = var.aws_nuke_lambda_function_role
  tags          = var.aws_nuke_lambda_function_tags
  handler       = "nuke.main.lambda_handler"
  environment {
    variables = var.aws_nuke_lambda_function_env_vars
  }
}