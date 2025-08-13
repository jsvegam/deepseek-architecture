# Gestiona el ConfigMap aws-auth SOLO con Terraform (sin kubectl, sin import)
# Requiere que var.account_b_node_role_arn esté definido en variables.tf (y valor en terraform.auto.tfvars)

locals {
  # Rol cross-account del nodo híbrido (Account B / Ohio)
  hybrid_map_roles = [
    {
      rolearn  = var.account_b_node_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
}

resource "kubernetes_manifest" "aws_auth" {
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "aws-auth"
      namespace = "kube-system"
    }
    data = {
      mapRoles = yamlencode(local.hybrid_map_roles)
    }
  }

  # Server-Side Apply con field_manager como bloque (sintaxis correcta)
  field_manager {
    name            = "terraform"
    force_conflicts = true
  }

  # Espera a que el cluster esté disponible (evita carreras)
  depends_on = [time_sleep.wait_eks_propagation]
}
