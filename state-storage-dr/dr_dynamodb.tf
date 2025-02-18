# Terraform 상태 잠금을 위한 DynamoDB 테이블 생성
resource "aws_dynamodb_table" "terraform_locks_dr" {
  name         = "terraform-locks-dr"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
