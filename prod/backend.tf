terraform {
 backend "s3" {
 bucket = "prod-snowduck-terraform-state"
 key = "prod/state-storage/terraform.tfstate"
 region = "ap-northeast-2"
 dynamodb_table = "prod-terraform-locks"
 encrypt = true
 }
}