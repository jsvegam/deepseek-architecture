locals {
  hybrid_map_roles = [{
    rolearn  = var.account_b_node_role_arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes"]
  }]
}

resource "kubernetes_manifest" "aws_auth" {
  count = var.manage_aws_auth_configmap ? 1 : 0

  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata   = { name = "aws-auth", namespace = "kube-system" }
    data       = { mapRoles = "[]" }
  }

  # Asegúrate de aplicar solo cuando el cluster esté listo
  depends_on = [
    module.eks,
    time_sleep.wait_eks_propagation
  ]
}
