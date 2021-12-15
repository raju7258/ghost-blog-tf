resource "aws_iam_user" "ghost-content-user" {
  name = "ghost-content-${var.env}-user"
  force_destroy = true
}

resource "aws_iam_access_key" "ghost-content-user-aksk" {
  user = aws_iam_user.ghost-content-user.name
}