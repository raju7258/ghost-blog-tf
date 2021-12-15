resource "aws_codestarconnections_connection" "codestar" {
  name          = "ghost-${var.env}-codestar"
  provider_type = "GitHub"
}