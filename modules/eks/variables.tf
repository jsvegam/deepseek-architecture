variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  description = "EKS version"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the cluster"
}

variable "desired_size" { type = number }
variable "min_size"     { type = number }
variable "max_size"     { type = number }

variable "instance_types" {
  type = list(string)
}

variable "capacity_type" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to EKS resources"
}


variable "cluster_admin_principal_arn" {
  type        = string
  description = "IAM principal to grant cluster-admin via EKS Access Entry"
}

