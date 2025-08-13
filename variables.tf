variable "eks_cluster_name" {
  type        = string
  default     = "my-eks-cluster"
  description = "Cluster name (Account A / Virginia)"
}

variable "enable_hybrid" {
  type        = bool
  default     = true
  description = "Toggle hybrid node module"
}

variable "account_b_node_role_arn" {
  type        = string
  description = "ARN of the hybrid node IAM role in Account B (Ohio)"
}
