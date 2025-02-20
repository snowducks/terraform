resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# 퍼블릭 서브넷 생성
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id           = aws_vpc.main.id
  cidr_block       = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = var.public_subnets_name[count.index]
  }
}

# 프라이빗 서브넷 생성
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id           = aws_vpc.main.id
  cidr_block       = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = var.private_subnets_name[count.index]
  }
}

# 인터넷 게이트웨이 생성 (퍼블릭 서브넷을 위한 연결)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internet_gateway
  }
}

# 퍼블릭 서브넷을 위한 라우트 테이블 생성
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_route_table
  }
}

# 퍼블릭 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "route_table_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# NAT 게이트웨이를 위한 탄력적 IP
resource "aws_eip" "nat_gateways" {
  count  = length(var.availability_zones)
  domain = "vpc"
}

# NAT 게이트웨이 생성 (프라이빗 서브넷이 인터넷에 나갈 수 있도록 설정)
resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.availability_zones)
  allocation_id = element(aws_eip.nat_gateways[*].id, count.index)
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index % length(var.public_subnet_cidrs))

  tags = {
    Name = var.nat_gateways[count.index]
  }
}

# 프라이빗 서브넷을 위한 라우트 테이블 생성
resource "aws_route_table" "private_route_tables" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateways[*].id, count.index)
  }

  tags = {
    Name = element(var.private_route_tables, count.index)
  }
}



# 프라이빗 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_route_tables[*].id, count.index)
}

