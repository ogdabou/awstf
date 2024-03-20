resource "aws_kms_key" "s3_objects_kms_encryption_key" {
  description = "Key used to encrypt s3 objects"
  deletion_window_in_days = 20
}

resource "aws_s3_bucket" "data_s3_bucket"  {
  bucket = "awstf-data"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.data_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_objects_kms_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
