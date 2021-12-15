output "out_aurora_kms" {
  value = data.aws_kms_key.aurora.arn
}

output "out_s3_kms" {
  value = data.aws_kms_key.s3.arn
}

output "out_s3_kms_sec" {
  value = data.aws_kms_key.s3_sec.arn
}

output "out_lambda_kms" {
  value = data.aws_kms_key.lambda.arn
}

# output "out_aurora_kms_dr"{
#   value = data.aws_kms_key.aurora_kms_dr
# }

# output "out_s3_sec_cmk_arn" {
#   value = aws_kms_key.s3_sec_cmk.arn
# }

# output "out_s3_pri_cmk_arn" {
#   value = aws_kms_key.s3_pri_cmk.arn
# }
