output "out_ghost_content_user_name" {
  value = aws_iam_user.ghost-content-user.name
}

output "out_ghost_content_user_arn" {
  value = aws_iam_user.ghost-content-user.arn
}

output "out_ghost_content_user_access_key" {
  value = aws_iam_access_key.ghost-content-user-aksk.id
}

output "out_ghost_content_user_secret_access_key" {
  value = aws_iam_access_key.ghost-content-user-aksk.secret
}