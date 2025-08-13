variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name in Account A (Virginia)"
  default     = "my-eks-cluster"  # <-- change if different
}

variable "enable_hybrid" {
  type        = bool
  description = "Enable/disable the hybrid node module"
  default     = true
}
