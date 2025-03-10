# HTTPS 리스너용 SSL 인증서 ARN
variable "certificate_arn" {
  description = "HTTPS 리스너에 사용할 SSL 인증서의 ARN"
  type        = string
}

# Aurora DB 마스터 계정 설정
variable "db_master_username" {
  description = "Aurora 데이터베이스의 마스터 사용자 이름"
  type        = string
  sensitive   = true  # 보안 정보 보호
}

variable "db_master_password" {
  description = "Aurora 데이터베이스의 마스터 비밀번호"
  type        = string
  sensitive   = true  # 보안 정보 보호
}
