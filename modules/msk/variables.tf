variable "vpc_id" {
  description = "VPC ID for MSK cluster"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for MSK brokers"
  type        = list(string)
}