resource "aws_cloudwatch_event_rule" "shutdown_rule" {
  name                = "shutdown-rule"
  description         = "Triggers Lambda to stop EC2 instance at 3 AM CET"
  schedule_expression = "cron(0 2 * * ? *)" # 3 AM CET = 2 AM UTC
}

resource "aws_cloudwatch_event_target" "shutdown_target" {
  rule      = aws_cloudwatch_event_rule.shutdown_rule.name
  target_id = "stop-instance"
  arn       = aws_lambda_function.stop_instance.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_rule.arn
}