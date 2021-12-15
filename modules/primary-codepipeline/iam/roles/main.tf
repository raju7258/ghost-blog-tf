resource "aws_iam_role" "iamrole" {
  for_each = var.iamroles
  name = each.value.rolename
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "${each.value.service}"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

