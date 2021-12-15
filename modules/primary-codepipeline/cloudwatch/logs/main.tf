resource "aws_cloudwatch_log_group" "ghost_td_cwlogs" {
  name = "/ecs/${var.var_td_family}"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

resource "aws_cloudwatch_log_group" "lambda-logs" {
  name              = "/aws/lambda/${var.var_lambda_function_name}"
}