output "out_codedeploy_appname" {
  value = aws_codedeploy_app.ghost-code-deploy.name
}

output "out_codedeploy_groupname" {
  value = local.deployment_group_name
}

output "out_codedeploy_app_arn" {
  value = aws_codedeploy_app.ghost-code-deploy.arn
}