pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    // environment {
    //     AWS_REGION = "ap-southeast-1"
    //     AWS_CREDENTIALS = "aws-ecr-credential"
    // }

    parameters {
        // DR 이벤트 여부를 원격 빌드 트리거 또는 다른 외부 시스템으로부터 전달받음
        booleanParam(name: 'dr_event', defaultValue: false, description: 'Is this a Disaster Recovery (DR) event?')
    }

    stages {
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Webhook Trigger Check') {
            steps {
                script {
                    if (!params.dr_event) {
                        error "Not a DR event. Aborting pipeline."
                    }
                    echo "DR 이벤트 감지"
                }
            }
        }

        // stage("Terraform Init") {
        //     steps {
        //         script {
        //             withAWS(credentials: AWS_CREDENTIALS, region: AWS_REGION) {
        //                 dir("./dr-eks") {
        //                     sh "terraform init"
        //                 }
        //             }
        //         }
        //     }
        // }
        
        // stage("Route53 Weight Update") {
        //     steps {
        //         // script {
        //         //     echo "Route53의 가중치 변경 실행 중..."
        //         //     // Route53 변경을 위한 JSON 파일이나 인라인 명령어 사용
        //         //     // 아래는 예시로, YOUR_ZONE_ID와 route53-change.json 파일은 실제 값으로 대체하세요.
        //         //     sh '''
        //         //         terraform apply \
        //         //             -target=aws_route53_record.prod \
        //         //             -target=aws_route53_record.dr_ecs \
        //         //             -target=aws_route53_record.dr_eks
        //         //     '''
        //         // }
        //         sleep time: 5, unit: 'SECONDS'
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

        // Helm CLI 설치(Helm 3)
        // stage("Install Helm on Jenkins Agent") {
        //     steps {
        //         script {
        //             sh """
        //               #!/usr/bin/env bash
        //               echo "Installing Helm 3..."
        //               curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        //               chmod 700 get_helm.sh
        //               ./get_helm.sh
        //               helm version
        //             """
        //         }
        //     }
        // }

        // Jenkins 에이전트 kubeconfig 설정
        // stage("Configure Kubeconfig for EKS") {
        //     steps {
        //         script {
        //             withAWS(credentials: AWS_CREDENTIALS, region: AWS_REGION) {
        //                 sh """
        //                   echo "Configuring kubeconfig for cluster: dr-eks-cluster"
        //                   aws eks update-kubeconfig --name dr-eks-cluster --region ${AWS_REGION}
        //                 """
        //             }
        //         }
        //     }
        // }

        // AWS Load Balancer Controller(구 ALB Ingress Controller) 설치
        // stage("Install AWS Load Balancer Controller") {
        //     steps {
        //         script {
        //             sh """
        //               # Helm Repo 추가
        //               helm repo add eks https://aws.github.io/eks-charts
        //               helm repo update

        //               # 이미 IRSA로 serviceAccount가 생성되었다고 가정
        //               # (Terraform에서 사전 작업 필요)
        //               helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
        //                 --namespace kube-system \
        //                 --set clusterName=dr-eks-cluster \
        //                 --set region=${AWS_REGION} \
        //                 --set serviceAccount.create=false \
        //                 --set serviceAccount.name=aws-load-balancer-controller
        //             """
        //         }
        //     }
        // }

        // --set clusterName=dr-eks-cluster
        // --set region=${AWS_REGION}
        // 필요 시 --set vpcId=vpc-123456 같은 방식으로 VPC ID를 지정해줄 수 있습니다(일부 경우 자동 인식).

        // ========== 4개 레포지토리를 순차적으로 배포 ==========
        
        // https://github.com/snowducks/helm-olive-young-fe.git
        // https://github.com/snowducks/helm-websocket-server.git
        // https://github.com/snowducks/helm-kafka-producer.git
        // https://github.com/snowducks/helm-kafka-consumer.git
        
        // stage("Deploy FE") {
        //     steps {
        //         script {
        //             // 1) FE 레파지토리 clone
        //             sh """
        //                 rm -rf fe
        //                 git clone https://github.com/snowducks/helm-olive-young-fe.git fe
        //             """

        //             // 2) FE Helm Chart 배포
        //             dir("fe/helm") {
        //                 sh """
        //                     helm upgrade -i fe . \
        //                         --namespace front \
        //                         --create-namespace \
        //                         -f values.yaml
        //                 """
        //             }
        //         }
        //     }
        // }
        // stage("Deploy WebSocket Server") {
        //     steps {
        //         script {
        //             // 1) websocket-server 레포지토리 clone
        //             sh """
        //               rm -rf websocket-server
        //               git clone https://github.com/snowducks/helm-websocket-server.git websocket-server
        //             """

        //             // 2) WebSocket Helm Chart 배포
        //             dir("websocket-server/helm") {
        //                 sh """
        //                   helm upgrade -i websocket-server . \
        //                     --namespace back \
        //                     -f values.yaml
        //                 """
        //             }
        //         }
        //     }
        // }

        // stage("Deploy Kafka Producer") {
        //     steps {
        //         script {
        //             // 1) kafka-producer 레포지토리 clone
        //             sh """
        //               rm -rf kafka-producer
        //               git clone https://github.com/snowducks/helm-kafka-producer.git kafka-producer
        //             """

        //             // 2) Producer Helm Chart 배포
        //             dir("kafka-producer/helm") {
        //                 sh """
        //                   helm upgrade -i kafka-producer . \
        //                     --namespace back \
        //                     -f values.yaml
        //                 """
        //             }
        //         }
        //     }
        // }

        // stage("Deploy Kafka Consumer") {
        //     steps {
        //         script {
        //             // 1) kafka-consumer 레포지토리 clone
        //             sh """
        //               rm -rf kafka-consumer
        //               git clone https://github.com/snowducks/helm-kafka-consumer.git kafka-consumer
        //             """

        //             // 2) Consumer Helm Chart 배포
        //             dir("kafka-consumer/helm") {
        //                 sh """
        //                   helm upgrade -i kafka-consumer . \
        //                     --namespace back \
        //                     -f values.yaml
        //                 """
        //             }
        //         }
        //     }
        // }

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