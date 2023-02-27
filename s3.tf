resource "aws_s3_bucket" "s3_private_log" {
  bucket = "logs.matsuhub"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
#resource "aws_s3_bucket" "codepipeline_artifact" {
#  bucket = "codepipeline-artifact.matsuhub"
#  acl    = "private"
#}
resource "aws_s3_bucket" "s3-stg-public" {
  bucket = "stg-static.matsuhub.link"
  policy = data.aws_iam_policy_document.stg-statics-acl.json
}
#resource "aws_s3_bucket_public_access_block" "s3-stg-public" {
#  bucket                  = aws_s3_bucket.s3-stg-public.bucket
#  block_public_acls       = true
#  block_public_policy     = false ## バケットポリシーで制御したいため無効にする。
#  ignore_public_acls      = true
#  restrict_public_buckets = false ## バケットポリシーで制御したいため無効にする。
#}
resource "aws_s3_bucket_acl" "s3-stg-public-acl" {
  bucket = aws_s3_bucket.s3-stg-public.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "s3_private_log_block" {
  bucket = aws_s3_bucket.s3_private_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#resource "aws_s3_bucket_policy" "allow_access_from_same_account" {
#  bucket = aws_s3_bucket.s3_private_log.id
#  policy = data.aws_iam_policy_document.allow_access_from_same_account.json
#}

data "aws_iam_policy_document" "allow_access_from_same_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["460987823234"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.s3_private_log.arn,
      "${aws_s3_bucket.s3_private_log.arn}/*",
    ]
  }
}


data "aws_iam_policy_document" "stg-statics-acl" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
        "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::stg-static.matsuhub.link",
      "arn:aws:s3:::stg-static.matsuhub.link/*"
    ]
  }
}
data "aws_iam_policy_document" "s3_private_log" {
  statement {
    effect    = "Allow"
    actions   = [ "s3:PutObject" ]
    resources = [ "${aws_s3_bucket.s3_private_log.arn}/*" ]
    principals {
      type = "AWS"
      identifiers = [ 
      aws_lb.stg-matsuhub-ecs-front.arn,
      aws_lb.stg-matsuhub-ecs-api.arn
      ]
    }
  }
}
resource "aws_s3_bucket_policy" "s3_private_log" {
  bucket = aws_s3_bucket.s3_private_log.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::582318560864:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::logs.matsuhub/logs/AWSLogs/460987823234/*"
    },
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "delivery.logs.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::logs.matsuhub/logs/AWSLogs/460987823234/*",
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
      "Resource": "arn:aws:s3:::logs.matsuhub"
    }
  ]
}
EOF
}

