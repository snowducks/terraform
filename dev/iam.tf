# IAM 역할 및 정책 설정

# Terraform으로 ECR을 생성 후 Jenkins가 AWS ECR에 로그인하고 이미지를 ECR에 푸시할 권한 부여

# 1. Jenkins의 IAM 역할 생성
resource "aws_iam_role" "jenkins_ecr_role" {
  name = "jenkins-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com" # Jenkins가 실행되는 환경
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# 2. Jenkins의 ECR 접근 정책 생성
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "jenkins-ecr-access-policy"
  description = "Allows Jenkins to push and pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [ # 이미지 다운로드, 업로드 권한 부여
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.dev_ecr.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# 3. IAM 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "jenkins_ecr_policy_attach" {
  policy_arn = aws_iam_policy.ecr_access_policy.arn
  role       = aws_iam_role.jenkins_ecr_role.name
}


# Jenkins IAM 역할의 이름과 ARN 출력
output "jenkins_ecr_role_name" {
  description = "Jenkins ECR IAM 역할의 이름"
  value       = aws_iam_role.jenkins_ecr_role.name
}

output "jenkins_ecr_role_arn" {
  description = "Jenkins ECR IAM 역할의 ARN"
  value       = aws_iam_role.jenkins_ecr_role.arn
}

# ECR 접근 정책의 이름과 ARN 출력
output "ecr_access_policy_name" {
  description = "Jenkins의 ECR 접근 정책 이름"
  value       = aws_iam_policy.ecr_access_policy.name
}

output "ecr_access_policy_arn" {
  description = "Jenkins의 ECR 접근 정책 ARN"
  value       = aws_iam_policy.ecr_access_policy.arn
}
