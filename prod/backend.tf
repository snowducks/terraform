terraform {
 backend "s3" {
 # Replace this with your bucket name!
 bucket = "prod-snowduck-terraform-state"
 key = "prod/state-storage/terraform.tfstate"
 region = "ap-northeast-2"
 # Replace this with your DynamoDB table name!
 dynamodb_table = "prod-terraform-locks"
 encrypt = true
 }
}