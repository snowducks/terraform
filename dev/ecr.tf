# ECR(Elastic Container Registry) : docker 컨테이너 이미지 저장소
# Jenkins가 Docker 이미지 빌드하고 ECR에 업로드 -> ECR에서 새로운 이미지가 푸시되었을 때 ArgoCD가 이미지 업데이트 감지 -> ArgoCD가 EKS에 배포

# ecr 리소스 생성
resource "aws_ecr_repository" "dev_ecr" {
  name                 = "dev-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_replication_configuration" "dev_ecr_replication" {
  replication_configuration {
    rule {
      destination {
        region       = "us-east-2"  # 복제할 대상 리전
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

# ecr 출력 값
# 출력된 ecr_repository_url 값을 Jenkins에서 사용
output "ecr_repository_url" {
  value = aws_ecr_repository.dev_ecr.repository_url
}


