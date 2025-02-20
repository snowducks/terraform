variable "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  type        = string
}

variable "vpc_name" {
  description = "VPC의 이름"
  type        = string
}

variable "public_subnets_name" {
  description = "퍼블릭 서브넷 이름"
  type        = list(string) 
}

variable "private_subnets_name" {
  description = "프라이빗 서브넷 이름"
  type        = list(string) 
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 목록"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 목록"
  type        = list(string)
}

variable "availability_zones" {
  description = "서브넷을 배치할 가용 영역 목록"
  type        = list(string)
}

variable "internet_gateway" {
  description = "인터넷 게이트웨이"
  type        = string
}

variable "public_route_table" {
  description = "퍼블릭 라우팅 테이블"
  type        = string
}

variable "private_route_tables" {
  description = "프라이빗 라우팅 테이블 리스트"
  type        = list(string)
}

variable "nat_gateways" {
  description = "NAT 게이트웨이"
  type        = list(string)
  default = []
}




