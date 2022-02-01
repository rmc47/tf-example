terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

variable "bucket_name" {
  description = "The name of the S3 bucket the product release app will upload installers to."
}

variable "dns_name" {
  description = "DNS name used to access the files hosted in the S3 bucket."
}

variable "iam_user" {
  description = "The name of the product release app IAM user which will be granted access to the S3 bucket"
}

variable "bucket_lifecycle_expiration_rules" {
  description = "A hash used to generate lifecycle_rule expirations for the cloudfront distribution."
  default = {}
}

locals {
  bucket_region = "us-east-1"
}

resource "aws_s3_bucket" "download-bucket" {
  bucket = var.bucket_name
  acl    = "private"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html" # <- Required for our index.html listing to work properly
  }

  dynamic "lifecycle_rule" {
    for_each = var.bucket_lifecycle_expiration_rules
    content {
      id = "expiration-${lifecycle_rule.key}"
      enabled = true
      prefix = lifecycle_rule.key

      expiration {
        days = lifecycle_rule.value
      }
    }
  }
}

resource "aws_s3_bucket_policy" "download-bucket-policy" {
  bucket = aws_s3_bucket.download-bucket.id

  policy = <<POLICY
{
  "Id": "download-bucket-policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid":"PublicReadForGetBucketObjects",
      "Action": [
        "s3:GetObject"
      ],
      "Effect":"Allow",
      "Resource": "${aws_s3_bucket.download-bucket.arn}/*",
      "Principal": "*"
    },
    {
      "Sid":"PublicReadForListBucket",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect":"Allow",
      "Resource": "${aws_s3_bucket.download-bucket.arn}",
      "Principal": "*"
    },
    {
      "Sid": "AllowProductReleaseToUploadDeleteObjects1",
      "Action": [
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.download-bucket.arn}/*",
      "Principal": {
        "AWS": "${aws_iam_user.user.arn}"
      }
    }
  ]
}
POLICY
}

# index.html based on https://github.com/rufuspollock/s3-bucket-listing
# Using templatefile() so that we can inject a couple of parameters
resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.download-bucket.id
  key    = "index.html"
  source = "${path.module}/website/index.html"
  etag   = filemd5("${path.module}/website/index.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "list-js" {
  bucket = aws_s3_bucket.download-bucket.id
  key    = ".index/list.js"
  content = templatefile("${path.module}/website/list.js.tmpl", {
    bucket_url = "https://${aws_s3_bucket.download-bucket.bucket_regional_domain_name}"
  })
  etag   = md5(templatefile("${path.module}/website/list.js.tmpl", {
    bucket_url = "https://${aws_s3_bucket.download-bucket.bucket_regional_domain_name}"
  }))
  content_type = "application/javascript"
}

resource "aws_iam_user" "user" {
  name = var.iam_user
}

resource "aws_iam_access_key" "access_key" {
  user    = aws_iam_user.user.name
}

output "secret_access_key" {
  value = aws_iam_access_key.access_key.secret
}
