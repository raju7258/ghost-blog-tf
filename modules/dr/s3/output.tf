
output "out_alb_sec_logs" {
  value = aws_s3_bucket.alb-logs.bucket
}

output "out_s3_codepipeline_artifacts" {
  value = aws_s3_bucket.codepipeline_artifacts.bucket
}

output "out_s3_codepipeline_artifacts_arn" {
  value = aws_s3_bucket.codepipeline_artifacts.arn
}