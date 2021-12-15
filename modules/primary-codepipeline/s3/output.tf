
output "out_s3_codepipeline_artifacts" {
  value = aws_s3_bucket.codepipeline_artifacts.bucket
}

output "out_s3_codepipeline_artifacts_arn" {
  value = aws_s3_bucket.codepipeline_artifacts.arn
}

output "out_s3_content_assets_arn" {
  value = aws_s3_bucket.ghost_assets.arn
}

output "out_s3_content_assets_name" {
  value = local.bucket_name
}

output "out_s3_content_assets_arn_destination" {
  value = aws_s3_bucket.ghost_assets_destination.arn
}

output "out_s3_content_assets_name_destination" {
  value = local.dest_bucket_name
}