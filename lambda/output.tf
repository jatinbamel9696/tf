output "lambda_arn" {
    value = aws_lambda_function.lambda.arn
    description = "manage access key lambda arn"
}