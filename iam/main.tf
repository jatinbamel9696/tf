resource "aws_iam_user" "user" {
  name = "test-user"
  permissions_boundary = var.pb
  tags = var.tags
}


resource "aws_iam_access_key" "test" {
  user = aws_iam_user.user.name
}

resource "aws_secretsmanager_secret" "test" {
  name        = "iam_credenial_test"
  description = "credentials for iam user"
  tags = var.tags
}

resource "aws_secretsmanager_secret_rotation" "test" {
  secret_id = aws_secretsmanager_secret.test.id
  rotation_lambda_arn = var.rotation_lambda_arn
  rotation_rules {
    automatically_after_days = 1
  }
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "test" {
  secret_id     = aws_secretsmanager_secret.test.id
  secret_string = jsonencode({ "UserName" = aws_iam_user.user.name, "AccessKeyID" = aws_iam_access_key.test.id, "SecretAccessKey" = aws_iam_access_key.test.secret })
}
