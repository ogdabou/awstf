resource "aws_s3_bucket" "athena_s3_bucket" {
  bucket = "athena-mydemo-bucket"
}

resource "aws_athena_database" "example" {
  name   = "maindb"
  bucket = aws_s3_bucket.athena_s3_bucket.id
}

resource "aws_athena_workgroup" "awstf_athena_workgroup" {
  name = "example"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_s3_bucket.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
    }
  }
}
