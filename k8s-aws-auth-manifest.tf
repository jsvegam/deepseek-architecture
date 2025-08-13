variable "account_b_node_role_arn" {
  type        = string
  description = "ARN del rol IAM del nodo híbrido en Account B (Ohio)"
  validation {
    condition     = can(regex("^arn:aws:iam::\\d{12}:role/", var.account_b_node_role_arn))
    error_message = "Debe ser un ARN de rol IAM válido (formato: arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME)"
  }
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    mapRoles = yamlencode([
      # Rol para los nodos del EKS
      {
        rolearn  = module.eks.eks_managed_node_groups.main.iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      # Rol cross-account (Account B)
      {
        rolearn  = var.account_b_node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }

  depends_on = [
    time_sleep.wait_for_cluster,
    module.eks.eks_managed_node_groups
  ]
}