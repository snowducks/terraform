resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2-key"
  public_key = file("./dev-key.pub")  # 로컬의 공개키 사용
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow access to Jenkins from Bastion"
  vpc_id = module.vpc.vpc_id

  ingress{
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]  # Bastion 서버에서만 허용
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]  # Bastion 서버에서만 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-security-group"
  description = "Allow SSH from the internet"
  vpc_id = module.vpc.vpc_id

  # SSH (포트 22) - 외부에서 접근 가능 (IP 제한 가능)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["115.88.240.0/24"]  # 보안상 특정 IP로 제한하는 것이 좋음
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# EC2: Jenkins (프라이빗 서브넷)
resource "aws_instance" "jenkin_instance" {
  ami             = "ami-0077297a838d6761d"  # Ubuntu Server 22.04
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.ec2_key.key_name
  subnet_id       = module.vpc.private_subnets[0]  # 프라이빗 서브넷 사용
  security_groups = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-server"
  }
}

# EC2: Bastion (퍼블릭 서브넷)
resource "aws_instance" "bastion_instance" {
  ami             = "ami-0077297a838d6761d"  # Ubuntu Server 22.04
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.ec2_key.key_name
  subnet_id       = module.vpc.public_subnets[0]  # 퍼블릭 서브넷 사용
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-server"
  }
}

# 출력값 (접속 정보 확인)
output "bastion_public_ip" {
  value = aws_instance.bastion_instance.public_ip
}

output "jenkins_private_ip" {
  value = aws_instance.jenkin_instance.private_ip
}
