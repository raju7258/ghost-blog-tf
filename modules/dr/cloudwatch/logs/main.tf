resource "aws_cloudwatch_log_group" "ghost_td_cwlogs" {
  name = "/ecs/${var.var_td_family}"
}