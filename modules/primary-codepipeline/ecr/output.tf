output "out_ecr_arn" {
  value = aws_ecr_repository.ecr_repo.arn
}
output "out_ecr_repo_url" {
  value = aws_ecr_repository.ecr_repo.repository_url
}

output "out_ecr_repo_name" {
  value = aws_ecr_repository.ecr_repo.name
}