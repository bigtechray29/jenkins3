resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Project     = var.project_name
    ManagedBy   = "terraform"
    Purpose     = "jenkins-pipeline-deploy"
  }
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
