variable "account_b_node_role_arn" {
  type        = string
  description = "ARN del rol IAM del nodo híbrido en Account B (Ohio)"
}

# Pega aquí lo que HOY tenga mapRoles (si lo conoces). Si no tienes nada, deja "[]".
locals {
  existing_map_roles_yaml = <<-YAML
  []
  YAML
}

locals {
  existing_map_roles = try(yamldecode(local.existing_map_roles_yaml), [])
  hybrid_entry = {
    rolearn  = var.account_b_node_role_arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes"]
  }
  final_map_roles = concat(local.existing_map_roles, [local.hybrid_entry])
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
      mapRoles = yamlencode(local.final_map_roles)
    }
  }

  field_manager   = "terraform"
  force_conflicts = true
  depends_on      = [time_sleep.wait_eks_propagation]
}


resource "null_resource" "delete_aws_auth" {
  depends_on = [module.eks.cluster_id]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl delete configmap aws-auth -n kube-system --ignore-not-found --kubeconfig <(echo '${module.eks.kubeconfig}')
    EOT
  }
}