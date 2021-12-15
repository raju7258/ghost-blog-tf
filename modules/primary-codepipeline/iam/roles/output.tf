output "out_codepipelinerole" {
  value = aws_iam_role.iamrole["role1"].id
}

output "out_codepipelinerolearn" {
  value = aws_iam_role.iamrole["role1"].arn
}

output "out_codebuildrole" {
  value = aws_iam_role.iamrole["role2"].name
}

output "out_codebuildrolearn" {
  value = aws_iam_role.iamrole["role2"].arn
}

output "out_ecstaskservicerolename" {
  value = aws_iam_role.iamrole["role3"].name
}

output "out_ecstaskservicerolearn" {
  value = aws_iam_role.iamrole["role3"].arn
}

output "out_codedeployrolename" {
  value = aws_iam_role.iamrole["role4"].name
}

output "out_codedeployrolearn" {
  value = aws_iam_role.iamrole["role4"].arn
}

output "out_s3replicationrolearn" {
  value = aws_iam_role.iamrole["role5"].arn
}

output "out_s3replicationrolename" {
  value = aws_iam_role.iamrole["role5"].name
}

output "out_lambdarolename" {
  value = aws_iam_role.iamrole["role6"].name
}

output "out_lambdarolearn" {
  value = aws_iam_role.iamrole["role6"].arn
}