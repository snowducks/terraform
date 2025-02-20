terraform {
 backend "s3" {
 # Replace this with your bucket name!
 bucket = "snowduck-dr-eks-terraform-state"
 key = "dr-eks/state-storage/terraform.tfstate"
 region = "us-east-2"
 # Replace this with your DynamoDB table name!
 dynamodb_table = "terraform-locks-dr-eks"
 encrypt = true
 }
}