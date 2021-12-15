resource "aws_lambda_function" "ghost-lambda-function" {
  function_name = "${var.var_lambda_function_name}"
  role = var.var_lambdarolearn

  environment {
    variables = {
        AdminAPIKey = "",
        ContentAPIKey = "",
        HOSTNAME = "${var.var_hostnames}",
        NAME = "${var.var_hostnames}",
        URL = "http://${var.var_hostnames}"
    }
  }
  kms_key_arn = var.var_lambda_kms
  package_type = "Zip"
  filename = "${path.module}/ghost-pkg.zip"
  runtime = "python3.9"
  handler  = "lambda_function.lambda_handler"
}