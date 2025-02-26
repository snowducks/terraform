pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    environment {
        AWS_REGION = "ap-southeast-1"
        AWS_CREDENTIALS = "aws-ecr-credential"
    }

    // parameters {
    //     // DR 이벤트 여부를 원격 빌드 트리거 또는 다른 외부 시스템으로부터 전달받음
    //     booleanParam(name: 'dr_event', defaultValue: false, description: 'Is this a Disaster Recovery (DR) event?')
    // }

    stages {
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        // stage('Webhook Trigger Check') {
        //     steps {
        //         script {
        //             if (!params.dr_event) {
        //                 error "Not a DR event. Aborting pipeline."
        //             }
        //             echo "DR 이벤트 감지"
        //         }
        //     }
        // }

        stage("Terraform Init") {
            steps {
                script {
                    withAWS(credentials: AWS_CREDENTIALS, region: AWS_REGION) {
                        dir("./dr-eks") {
                            sh "terraform init"
                        }
                    }
                }
            }
        }
        
        // stage("Route53 Weight Update") {
        //     steps {
        //         script {
        //             echo "Route53의 가중치 변경 실행 중..."
        //             // Route53 변경을 위한 JSON 파일이나 인라인 명령어 사용
        //             // 아래는 예시로, YOUR_ZONE_ID와 route53-change.json 파일은 실제 값으로 대체하세요.
        //             sh '''
        //                 terraform apply \
        //                     -target=aws_route53_record.prod \
        //                     -target=aws_route53_record.dr_ecs \
        //                     -target=aws_route53_record.dr_eks
        //             '''
        //         }
        //     }
        // }
    
        // stage("eks Apply") {
        //     steps {
        //         echo "eks.tf 파일 기반으로 EKS 클러스터 생성/업데이트..."
        //         dir("./dr-eks") {
        //             // 먼저 plan을 수행한 후, apply 실행 (tfplan 파일은 필요에 따라 사용)
        //             sh '''
        //                 terraform apply \
        //                     -target=module.dr_eks \
        //                     -target=module.eks_aws_auth \
        //                     -target=data.aws_eks_cluster.dr_eks_cluster \
        //                     -target=data.aws_eks_cluster_auth.dr_eks_cluster_path \
        //                     -target=provider.kubernetes \
        //                     -target=aws_security_group.dr_eks_sg
        //             '''
        //         }
        //     }
        // }

        //
        stage("Download Helm Chart") {
            steps{

            }
        }
        
        //helm install {이름} . -f values.yaml -n front
        //helm install {이름} . -f values.yaml -n back 


    
        // 여기가 stage 끝임
    }

    post {
        success {
            slackSend channel: '#snowduck-alert', message: "DR 구축 완료"
        }
        failure {
            slackSend channel: '#snowduck-alert', message: "DR 구축 실패"
        }
    }
}