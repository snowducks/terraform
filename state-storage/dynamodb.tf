# Terraform 상태 잠금을 위한 DynamoDB 테이블 생성
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#resource "aws_dynamodb_table" "terraform_iam_locks" {
#  name         = "terraform-iam-locks"
#  billing_mode = "PAY_PER_REQUEST"
#  hash_key     = "LockID"
#
#  attribute {
#    name = "LockID"
#    type = "S"
#  }
#}
