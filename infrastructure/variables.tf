variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Resource prefix"
  default     = "staging"
}

variable "alarm_email" {
  type        = string
  description = "Email to subscribe to SNS alerts"
  default     = "you@example.com"
}
