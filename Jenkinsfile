pipeline {
    agent any

    stages {
        stage("Terraform Init") {
            steps {
                echo "Terraform 환경 초기화 (dr-eks 디렉토리)..."
                // SCM에서 체크아웃된 코드 내 terraform/dr-eks 디렉토리로 이동 후 terraform init 실행
                dir("terraform/dr-eks") {
                    sh "terraform init"
                }
            }
        }
        /*
        stage("Route53 Weight Update") {
            steps {
                script {
                    echo "Route53의 가중치 변경 실행 중..."
                    // Route53 변경을 위한 JSON 파일이나 인라인 명령어 사용
                    // 아래는 예시로, YOUR_ZONE_ID와 route53-change.json 파일은 실제 값으로 대체하세요.
                    sh '''
                      aws route53 change-resource-record-sets \
                        --hosted-zone-id YOUR_ZONE_ID \
                        --change-batch file://route53-change.json
                    '''
                }
            }
        }*/


    /*
        stage("Terraform Apply") {
            steps {
                echo "eks.tf 파일 기반으로 EKS 클러스터 생성/업데이트..."
                dir("terraform/dr-eks") {
                    // 먼저 plan을 수행한 후, apply 실행 (tfplan 파일은 필요에 따라 사용)
                    sh "terraform plan -target eks -out=tfplan"
                    sh "terraform apply -auto-approve tfplan"
                }
            }
        }

        stage("Install ArgoCD & Ingress") {
            steps {
                echo "생성된 EKS 클러스터에 ArgoCD 및 Ingress 설치..."
                // 아래는 예시로, 실제 클러스터 설정에 따라 설치 스크립트를 수정하세요.
                sh '''
                  # ArgoCD 설치
                  kubectl create namespace argocd || true
                  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

                  # Ingress Controller 설치 (예: Nginx Ingress)
                  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml
                '''
            }
        }

        stage("Deploy via ArgoCD/Helm") {
            steps {
                echo "ArgoCD를 통해 Helm chart를 이용한 애플리케이션 배포 (ECR 이미지 반영)..."
                // ArgoCD는 내부적으로 ECR의 최신 이미지를 읽어 배포하도록 구성되어 있어야 합니다.
                // ArgoCD CLI를 통해 애플리케이션을 동기화 하는 예시입니다.
                sh '''
                  # 예시: "your-application-name" 애플리케이션 동기화
                  argocd app sync your-application-name
                '''
            }
        }
        */
    }

    post {
        success {
            echo "Jenkins pipeline이 성공적으로 완료되었습니다."
        }
        failure {
            echo "Jenkins pipeline 실행 중 문제가 발생하였습니다."
        }
    }
}
