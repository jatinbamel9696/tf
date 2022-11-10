##lambda role for key rotation
resource "aws_iam_role" "role" {
  name = "key_rotation-role"
  tags = var.tags
  assume_role_policy = jsonencode({
    
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"    
            },
            "Action": "sts:AssumeRole"
        }
    ]

  })
}

## policy for the role key rotation
resource "aws_iam_policy" "policy" {
  name        = "iam_key_auto_rotation-policy"
  path        = "/"
  description = "iam_key_auto_rotation"
  tags = var.tags
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "iam:DeleteAccessKey",
          "secretsmanager:GetSecretValue",
          "iam:UpdateAccessKey",
          "secretsmanager:ListSecrets",
          "secretsmanager:UpdateSecret",
          "iam:CreateAccessKey",
          "iam:ListAccessKeys"
        ],
        "Resource" : "*"
      }
    ]
  })
}

## policy attached to the key rotation role
resource "aws_iam_role_policy_attachment" "role_policy" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

## archive file for key rotation lambda function 

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/create_key.py"
  output_path = "${path.module}/python/create_key.py.zip"
}


## lambda function for key rotation
resource "aws_lambda_function" "lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = "manage_access"
  role          = aws_iam_role.role.arn
  handler       = "create_key.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      secrets = "iam_credenial"
    }
  }
  tags = var.tags
}

## allow secret manager to call lambda function
resource "aws_lambda_permission" "allow_secret_manager_call_Lambda" {
    function_name = aws_lambda_function.lambda.function_name
    statement_id = "AllowExecutionSecretManager"
    action = "lambda:InvokeFunction"
    principal = "secretsmanager.amazonaws.com"
}



## archive file for key deleteion lambda function 
data "archive_file" "lambda_delete" {
  type        = "zip"
  source_file = "${path.module}/python/delete_key.py"
  output_path = "${path.module}/python/delete_key.py.zip"
}


#lambda function for delete the key
resource "aws_lambda_function" "lambda_delete" {
  filename      = data.archive_file.lambda_delete.output_path
  function_name = "delete_inactive_key"
  role          = aws_iam_role.role.arn
  handler       = "delete_key.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      secrets = "iam_credenial"
    }
  }
  tags = var.tags
}

##cloud watch event function

resource "aws_cloudwatch_event_rule" "every_one_hour" {
    name = "every-one-hour"
    description = "Fires every one hour"
    schedule_expression = "rate(1 hour)"
    tags = var.tags
}

resource "aws_cloudwatch_event_target" "check_every_five_minutes" {
    rule = aws_cloudwatch_event_rule.every_one_hour.name
    target_id = "test"
    arn = aws_lambda_function.lambda_delete.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_function" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_delete.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_one_hour.arn
}