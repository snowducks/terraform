# S3 버킷 생성 (Terraform State 저장소)
resource "aws_s3_bucket" "prod_terraform_state" {
  bucket = "prod-snowduck-terraform-state"
}

# S3 버킷에 버전 관리 활성화
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.prod_terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 서버 사이드 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.prod_terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 퍼블릭 액세스 완전 차단
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.prod_terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
