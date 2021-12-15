output "out_cluster_identifier" {
  value = aws_rds_cluster.cluster.cluster_identifier
}

output "out_database_name" {
  value = aws_rds_cluster.cluster.database_name
}

output "out_database_writer_endpoint" {
  value = aws_rds_cluster.cluster.endpoint
}