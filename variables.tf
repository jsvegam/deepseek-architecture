variable "eks_cluster_name" {
  type        = string
  default     = "my-eks-cluster"
  description = "Cluster name (Account A / Virginia)"
}


variable "account_b_node_role_arn" {
  type        = string
  description = "ARN of the hybrid node IAM role in Account B (Ohio)"
}


variable "cluster_admin_principal_arn" {
  type        = string
  description = "IAM principal (user/role) that should be cluster admin for initial access"
}
