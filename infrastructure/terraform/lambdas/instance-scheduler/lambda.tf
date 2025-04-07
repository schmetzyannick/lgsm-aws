resource "aws_iam_role" "lambda_stop_instance_role" {
  name = "lambda-stop-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_stop_instance_policy" {
  name        = "lambda-stop-instance-policy"
  description = "Policy to allow Lambda to stop EC2 instances"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_stop_instance_policy_attachment" {
  role       = aws_iam_role.lambda_stop_instance_role.name
  policy_arn = aws_iam_policy.lambda_stop_instance_policy.arn
}

resource "aws_lambda_function" "stop_instance" {
  function_name    = "stop-instance"
  role             = aws_iam_role.lambda_stop_instance_role.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = "${path.module}/../../../../lambdas/instance-scheduler/lambda.zip" # Path to your Lambda deployment package
  source_code_hash = filebase64sha256("${path.module}/../../../../lambdas/instance-scheduler/lambda.zip")
  timeout          = 30 # Timeout in seconds

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}
