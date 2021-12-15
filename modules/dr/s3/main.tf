data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "alb-logs" {
  bucket = "ghost-${var.env}-alb-logs"
  acl = "private"
  force_destroy = true

}

resource "aws_s3_bucket_policy" "alb-s3-logs-policy" {
  bucket = aws_s3_bucket.alb-logs.id
  policy = jsonencode({

  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alb-logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alb-logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alb-logs.bucket}"
    }
  ]
  })
}

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "ghost-pipeline-artifacts-${var.env}"
  acl    = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.var_s3_kms_sec_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  
}
