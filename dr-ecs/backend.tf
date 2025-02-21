terraform {
 backend "s3" {
 # Replace this with your bucket name!
 bucket = "dr-ecs-snowduck-terraform-state"
 key = "dr-ecs/state-storage/terraform.tfstate"
 region = "ap-southeast-1"
 # Replace this with your DynamoDB table name!
 dynamodb_table = "dr-ecs-terraform-locks"
 encrypt = true
 }
}