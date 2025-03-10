# Terraform 상태 저장소를 S3 백엔드로 설정
terraform {
  backend "s3" {
    bucket         = "dr-eks-snowduck-terraform-state"  
    key            = "dr-eks/state-storage/terraform.tfstate"  
    region         = "ap-southeast-1" 
    dynamodb_table = "dr-eks-terraform-locks" 
    encrypt        = true 
  }
}
