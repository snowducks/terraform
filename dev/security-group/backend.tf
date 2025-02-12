terraform {
 backend "s3" {
 # Replace this with your bucket name!
 bucket = "snowduck-terraform-state"
 key = "dev/state-storage/terraform.tfstate"
 region = "ap-northeast-2"
 # Replace this with your DynamoDB table name!
 dynamodb_table = "terraform-locks"
 encrypt = true
 }
}