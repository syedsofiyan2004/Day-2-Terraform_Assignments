provider "aws" {
  region=var.aws_region
}

resource "aws_s3_bucket" "static_website" {
  bucket=var.bucket_name

  tags = {
    Name="S3 Static Website"
    Owner="Syed Sofiyan"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket=aws_s3_bucket.static_website.id
  block_public_acls=false
  block_public_policy=false
  ignore_public_acls=false
  restrict_public_buckets=false
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket=aws_s3_bucket.static_website.id

  index_document {
    suffix="index.html"
  }
}

data "aws_iam_policy_document" "public_read" {
  statement {
    actions=["s3:GetObject"]
    resources=["${aws_s3_bucket.static_website.arn}/*"]
    principals {
      type= "AWS"
      identifiers=["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket=aws_s3_bucket.static_website.id
  policy=data.aws_iam_policy_document.public_read.json
}

resource "aws_s3_object" "index_html" {
  bucket=aws_s3_bucket.static_website.bucket
  key="index.html"
  source="${path.module}/index.html"
  content_type = "text/html"
}
