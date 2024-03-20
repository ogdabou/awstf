resource "aws_kms_key" "s3_objects_kms_encryption_key" {
  description = "Key used to encrypt s3 objects"
  deletion_window_in_days = 20
}
