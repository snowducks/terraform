variable "certificate_arn" {
  description = "HTTPS 리스너용 SSL 인증서 ARN"
  type        = string
}

variable "db_master_username" {
  description = "Aurora DB 마스터 사용자명"
  type        = string
  sensitive   = true
}

variable "db_master_password" {
  description = "Aurora DB 마스터 비밀번호"
  type        = string
  sensitive   = true
}
