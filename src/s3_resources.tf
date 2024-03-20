resource "aws_s3_object" "lottery_winning_numbers_s3_bucket_object" {
  content_type = "csv"
  source = "../../src/resources/Lottery_Mega_Millions_Winning_Numbers__Beginning_2002.csv"
  bucket = aws_s3_bucket.data_s3_bucket.id
  key = "csv/lottery.mega_millions_winning_numbers.beginning.2002.csv"
  kms_key_id = aws_kms_key.s3_objects_kms_encryption_key.arn
}
