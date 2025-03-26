variable "vpc_id" {
  description = "VPC ID for RDS"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for RDS"
  type        = list(string)
}