output "lambda_function_name" {
  value       = aws_lambda_function.main.function_name
  description = "作成された Lambda 関数の名前"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.main.arn
  description = "作成された Lambda 関数の arn"
}

output "lambda_invoke_arn" {
  value       = aws_lambda_function.main.invoke_arn
  description = "作成された Lambda 関数の invoke_arn"
}

output "ecr_repo_arn" {
  value       = aws_ecr_repository.main.arn
  description = "作成された Lambda 関数の invoke_arn"
}

output "lambda_function_url" {
  value       = aws_lambda_function_url.main[0].function_url
}
