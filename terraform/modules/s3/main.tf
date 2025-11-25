# ============================================
# S3 MODULE - MAIN CONFIGURATION
# ============================================
# Módulo reutilizável para criação de buckets S3

# ============================================
# RANDOM SUFFIX FOR UNIQUE BUCKET NAMES
# ============================================
resource "random_string" "suffix" {
  count = var.use_random_suffix ? 1 : 0
  
  length  = 8
  special = false
  upper   = false
}

# ============================================
# S3 BUCKET
# ============================================
resource "aws_s3_bucket" "main" {
  bucket = var.use_random_suffix ? "${var.bucket_name}-${random_string.suffix[0].result}" : var.bucket_name

  tags = merge(var.tags, {
    Name = var.bucket_name
  })
}

# ============================================
# BUCKET VERSIONING
# ============================================
resource "aws_s3_bucket_versioning" "main" {
  count = var.enable_versioning ? 1 : 0
  
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================
# BUCKET ENCRYPTION
# ============================================
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count = var.enable_encryption ? 1 : 0
  
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_algorithm
    }
  }
}

# ============================================
# BUCKET PUBLIC ACCESS BLOCK
# ============================================
resource "aws_s3_bucket_public_access_block" "main" {
  count = var.block_public_access ? 1 : 0
  
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================
# BUCKET LIFECYCLE CONFIGURATION
# ============================================
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0
  
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", null) != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration", null) != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }
    }
  }
}

# ============================================
# BUCKET POLICY
# ============================================
resource "aws_s3_bucket_policy" "main" {
  count = var.bucket_policy != null ? 1 : 0
  
  bucket = aws_s3_bucket.main.id
  policy = var.bucket_policy
}
