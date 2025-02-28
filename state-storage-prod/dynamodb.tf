# 테라폼 상태 잠금을 위한 DynamoDB 테이블 생성
resource "aws_dynamodb_table" "prod_terraform_locks" {
  name         = "prod-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

