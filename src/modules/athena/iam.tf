
data aws_iam_policy_document "athena_reader_policy" {
  statement {
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryExecution",
      "athena:ListQueryExecutions",
      "athena:ListDatabases",
      "athena:GetDatabase",
      "athena:StopQueryExecution"
    ]
    resources = [aws_athena_workgroup.awstf_athena_workgroup.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "${aws_s3_bucket.athena_s3_bucket.arn}/*",
      "${var.bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [aws_iam_user.athena_reader_iam_user.arn]
  }
}

resource "aws_iam_role" "athena_reader_iam_role" {
  name = "athena_reader"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "${aws_iam_user.athena_reader_iam_user.arn}"
            ]
          },
          "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "athena_reader_role_policy" {
  name       = "athena_reader_role_policy"
  policy     = data.aws_iam_policy_document.athena_reader_policy.json
  role       = aws_iam_role.athena_reader_iam_role.id
}

resource "aws_iam_user" "athena_reader_iam_user" {
  name = "athena_reader"
}

resource "aws_iam_access_key" "athena_reader_access_key" {
  user    = aws_iam_user.athena_reader_iam_user.name
}

## This should be replaced by something else, like putting the keys inside a vault or something
## Or AWS secret manager

output "iam_access_key_id" {
  description = "The access key ID"
  value       = aws_iam_access_key.athena_reader_access_key.id
}

output "iam_secret_access_key" {
  description = "The secret access key. This will be written to the state file so should be treated as sensitive data."
  value       = aws_iam_access_key.athena_reader_access_key.secret
  sensitive   = true
}