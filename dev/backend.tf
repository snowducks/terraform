terraform {
 backend "s3" {
 bucket = "snowduck-terraform-state"
 key = "dev/state-storage/terraform.tfstate"
 region = "ap-northeast-2"
 dynamodb_table = "terraform-locks"
 encrypt = true
 }
}