resource "aws_iam_role" "lambda_role" {
  name = "vm-management-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "vm-management-ec2-policy"
  description = "Policy to allow Lambda to manage EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "null_resource" "npm_install" {
  provisioner "local-exec" {
    command     = "npm install"
    working_dir = "${path.module}/../../../../lambdas/vm-management"
  }
}

resource "null_resource" "npm_build" {
  provisioner "local-exec" {
    command     = "npm run bundle-prod"
    working_dir = "${path.module}/../../../../lambdas/vm-management"
  }
  depends_on = [null_resource.npm_install]
}

resource "aws_lambda_function" "vm_management" {
  function_name    = "vm-management"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = "${path.module}/../../../../lambdas/vm-management/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../../lambdas/vm-management/lambda.zip")

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }

  depends_on = [null_resource.npm_build]
}
