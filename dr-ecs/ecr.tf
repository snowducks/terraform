
resource "aws_ecr_repository" "dr_ecr" {
  name                 = "dev-ecr" # ECR 복제는 같은 이름의 리포지토리끼리 동작하므로 dev의 ECR 이미지를 가져오기 위해 dev-ecr로 설정
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}