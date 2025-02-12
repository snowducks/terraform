variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "s3_bucket_name" {
  description = "Terraform 상태 저장소 S3 버킷 이름"
  type        = string
  default     = "snowduck-terraform-state"
}

variable "dynamodb_table_name" {
  description = "Terraform 상태 잠금용 DynamoDB 테이블 이름"
  type        = string
  default     = "terraform-locks"
}
