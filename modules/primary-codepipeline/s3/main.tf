data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "ghost-pipeline-artifacts-${var.env}"
  acl    = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.var_s3_kms_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  
}

resource "aws_s3_bucket" "codebuild_artifacts" {
  bucket = "ghost-codebuild-artifacts-${var.env}"
  acl    = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.var_s3_kms_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket" "alb-logs" {
  bucket = "ghost-${var.env}-alb-logs"
  acl = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.var_s3_kms_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
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
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alb-logs.bucket}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alb-logs.bucket}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
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

locals {
  bucket_name = "ghost-${var.env}-assets"
}


resource "aws_s3_bucket" "ghost_assets" {
  bucket = local.bucket_name
  acl = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.var_s3_kms_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

locals {
  dest_bucket_name = "ghost-${var.env}-assets-dest"
}

resource "aws_s3_bucket" "ghost_assets_destination" {
  provider = aws.secondary
  bucket = local.dest_bucket_name
  acl = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.var_s3_kms_sec_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "ghost-asset-replication" {
  role = var.var_s3replicationrolearn
  bucket = aws_s3_bucket.ghost_assets.id

  rule {
    id = "asset-replication"
    prefix = "2021/"
    status = "Enabled"
    
    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    destination {
      bucket = aws_s3_bucket.ghost_assets_destination.arn
      storage_class = "STANDARD"
      encryption_configuration {
        replica_kms_key_id = "${var.var_s3_kms_sec_arn}"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "secondary-assets-bucket-policy" {
  provider = aws.secondary
  bucket = aws_s3_bucket.ghost_assets_destination.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "S3PolicyStmt",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": [
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning",
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Resource": [
            "${aws_s3_bucket.ghost_assets_destination.arn}",
            "${aws_s3_bucket.ghost_assets_destination.arn}/*"
        ]
      }
    ]  
  })
}