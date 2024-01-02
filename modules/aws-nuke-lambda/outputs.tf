output "nuke-function-arn" {
  value = aws_lambda_function.nuke-function.arn
}

output "nuke-function-name" {
  value = aws_lambda_function.nuke-function.function_name
}