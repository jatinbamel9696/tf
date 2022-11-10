output "secret_manager" {
  value = aws_secretsmanager_secret.test.name
}
