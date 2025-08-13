variable "account_b_node_role_arn" {
  type        = string
  description = "ARN del rol IAM del nodo híbrido en Account B (Ohio)"
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    # Construimos mapRoles en YAML con yamlencode para evitar errores de formato
    mapRoles = yamlencode([
      {
        rolearn  = var.account_b_node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }

  # Espera a que el EKS esté propagado si ya tienes el time_sleep
  depends_on = [time_sleep.wait_eks_propagation]
}
