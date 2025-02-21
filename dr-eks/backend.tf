terraform {
 backend "s3" {
 # Replace this with your bucket name!
 bucket = "dr-eks-snowduck-terraform-state"
 key = "dr-eks/state-storage/terraform.tfstate"
 region = "ap-southeast-1"
 # Replace this with your DynamoDB table name!
 dynamodb_table = "dr-eks-terraform-locks"
 encrypt = true
 }
}