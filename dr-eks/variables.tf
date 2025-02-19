variable "certificate_arn" {
  description = "The ARN of the SSL certificate for HTTPS listener"
  type        = string
}

variable "db_master_username" {
  description = "Aurora DB Master Username"
  type        = string
  sensitive   = true
}

variable "db_master_password" {
  description = "Aurora DB Master Password"
  type        = string
  sensitive   = true
}
