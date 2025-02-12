output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "프라이빗 서브넷 ID 목록"
  value       = aws_subnet.private[*].id
}
