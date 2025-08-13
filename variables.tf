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

