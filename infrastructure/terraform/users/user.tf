resource "aws_iam_user" "game_server_user" {
  name = "game-server-user-start-stop"
}

resource "aws_iam_user_login_profile" "game_server_user_login_start_stop" {
  user            = aws_iam_user.game_server_user.name
  password_length = 32
}

resource "aws_iam_policy" "game_server_policy" {
  name        = "game-server-policy"
  description = "Policy to allow user to display EC2 instances and start/stop them"
  policy = jsonencode({
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

resource "aws_iam_user_policy_attachment" "game_server_user_policy_attachment" {
  user       = aws_iam_user.game_server_user.name
  policy_arn = aws_iam_policy.game_server_policy.arn
}

resource "aws_iam_user" "admin_user" {
  name = "admin-user"
}

resource "aws_iam_user_policy_attachment" "admin_user_policy_attachment" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # AWS-managed admin policy
}

resource "aws_iam_access_key" "admin_user_access_key" {
  user = aws_iam_user.admin_user.name
}

output "admin_user_access_key_id" {
  value       = aws_iam_access_key.admin_user_access_key.id
  sensitive   = true
}

output "admin_user_secret_access_key" {
  value       = aws_iam_access_key.admin_user_access_key.secret
  sensitive   = true
}

output "password" {
  value = aws_iam_user_login_profile.game_server_user_login_start_stop.encrypted_password
}