variable "eks_cluster_name" {
  description = "EKS cluster to join"
  type        = string
}

variable "hybrid_vpc_id" {
  description = "VPC ID in the region where the EC2 hybrid node will live (Ohio)"
  type        = string
}

variable "hybrid_subnet_id" {
  description = "Subnet ID where EC2 will be launched"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the hybrid node"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Optional EC2 key pair name (use SSM Session Manager if null)"
  type        = string
  default     = null
}

variable "create_access_entry" {
  description = "Create EKS access entry/policy association in the EKS control-plane region"
  type        = bool
  default     = true
}

variable "ssm_registration_limit" {
  description = "Max registrations allowed by the SSM Activation"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}


variable "eks_cluster_region" {
  description = "Region of the EKS control plane (e.g., us-east-1)"
  type        = string
}

variable "hybrid_region" {
  description = "Region where the EC2/SSM hybrid node runs (e.g., us-east-2)"
  type        = string
}

