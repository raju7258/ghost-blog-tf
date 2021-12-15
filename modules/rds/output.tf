output "out_cluster_identifier" {
  value = aws_rds_cluster.cluster.cluster_identifier
}

output "out_cluster_arn" {
  value = aws_rds_cluster.cluster.arn
}

output "out_ssm_database_username" {
  value = aws_ssm_parameter.username.name
}

output "out_ssm_database_password" {
  value = aws_ssm_parameter.password.name
}

output "out_database_name" {
  value = aws_rds_cluster.cluster.database_name
}

output "out_database_writer_endpoint" {
  value = aws_rds_cluster.cluster.endpoint
}

output "out_ssm_database_username_value" {
  value = aws_ssm_parameter.username.value
}

output "out_ssm_database_password_value" {
  value = aws_ssm_parameter.password.value
}