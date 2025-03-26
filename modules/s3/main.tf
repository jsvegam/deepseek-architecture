# S3 Bucket (was missing declaration)
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# Lifecycle Configuration (corrected)
resource "aws_s3_bucket_lifecycle_configuration" "cost_optimization" {
  bucket = aws_s3_bucket.bucket.id  # Now references declared bucket

  rule {
    id = "cost-saving"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    status = "Enabled"
  }
}