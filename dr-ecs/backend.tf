terraform {
 backend "s3" {
 # Replace this with your bucket name!
 bucket = "snowduck-dr-ecs-terraform-state"
 key = "dr-ecs/state-storage/terraform.tfstate"
 region = "us-east-2"
 # Replace this with your DynamoDB table name!
 dynamodb_table = "terraform-locks-dr-ecs"
 encrypt = true
 }
}