data "aws_kms_key" "aurora" {
  key_id = "alias/aws/rds"
}

data "aws_kms_key" "s3" {
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "s3_sec" {
  provider = aws.secondary
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "lambda" {
  key_id = "alias/aws/lambda"
}

# data "aws_kms_key" "aurora_kms_dr" {
#   provider = aws.secondary
#   key_id = "alias/aws/rds"
# }

# resource "aws_kms_key" "s3_sec_cmk" {
#   provider = aws.secondary
#   # policy = var.var_kms_policy_id
# }

# resource "aws_kms_key" "s3_pri_cmk" {
  
# }

# resource "aws_kms_alias" "s3_sec_cmk_alias" {
#   provider = aws.secondary
#   name          = "alias/s3_sec_cmk"
#   target_key_id = aws_kms_key.s3_sec_cmk.key_id
# }

# resource "aws_kms_alias" "s3_pri_cmk_alias" {
#   name          = "alias/s3_priv_cmk"
#   target_key_id = aws_kms_key.s3_pri_cmk.key_id

# }

# resource "aws_iam_role" "kms-s3-role" {
#   name = "kms-s3-role"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "s3.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }

# resource "aws_kms_grant" "kms_grant_sec_cmk" {
#   provider          = aws.secondary
#   name              = "kms_grant_sec"
#   key_id            = aws_kms_key.s3_sec_cmk.key_id
#   grantee_principal = var.var_s3replicationrolearn
#   operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
# }