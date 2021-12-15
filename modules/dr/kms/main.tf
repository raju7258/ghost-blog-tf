data "aws_kms_key" "aurora_kms_dr" {
  key_id = "alias/aws/rds"
}
