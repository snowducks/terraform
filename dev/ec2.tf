resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2-key"
  public_key = file("./dev-key.pub")
}

# jenkins 올라가있는 ec2 보안그룹
resource "aws_security_group" "dev_jenkins_sg" {
  name        = "dev-jenkins-security-group"
  description = "Bastion에서 Jenkins로의 접근 허용"
  vpc_id = module.dev_vpc.vpc_id

  ingress{
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dev_bastion_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.dev_bastion_sg.id]
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

resource "aws_security_group" "dev_bastion_sg" {
  name        = "dev-bastion-security-group"
  description = "Allow SSH from the internet"
  vpc_id = module.dev_vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 보안상 특정 IP 제한 필요
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

# EC2 Jenkins 서버
resource "aws_instance" "dev_jenkin_instance" {
  ami             = "ami-0077297a838d6761d"  # Ubuntu Server 22.04
  instance_type   = "t3.large"
  key_name        = aws_key_pair.ec2_key.key_name
  subnet_id       = module.dev_vpc.private_subnets[0]
  security_groups = [aws_security_group.dev_jenkins_sg.id]

  tags = {
    Name = "jenkins-server"
  }
}

# EC2 Bastion 서버
resource "aws_instance" "dev_bastion_instance" {
  ami             = "ami-0077297a838d6761d"  # Ubuntu Server 22.04
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.ec2_key.key_name
  subnet_id       = module.dev_vpc.public_subnets[0]
  security_groups = [aws_security_group.dev_bastion_sg.id]

  tags = {
    Name = "dev-bastion-server"
  }
}

resource "aws_eip" "dev_bastion_eip" {
  instance = aws_instance.dev_bastion_instance.id
  domain   = "vpc"

  tags = {
    Name = "dev-bastion-eip"
  }
}

output "dev_bastion_public_ip" {
  description = "dev 환경 bastion 인스턴스 공인 IP"
  value = aws_instance.dev_bastion_instance.public_ip
}

output "dev_jenkins_private_ip" {
  description = "dev 환경 Jenkins 인스턴스 사설 IP"
  value = aws_instance.dev_jenkin_instance.private_ip
}
