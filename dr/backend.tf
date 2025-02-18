terraform {
 backend "s3" {
 # Replace this with your bucket name!
 bucket = "snowduck-dr-terraform-state"
 key = "dr/state-storage/terraform.tfstate"
 region = "us-east-2"
 # Replace this with your DynamoDB table name!
 dynamodb_table = "terraform-locks-dr"
 encrypt = true
 }
}