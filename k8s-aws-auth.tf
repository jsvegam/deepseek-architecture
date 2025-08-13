locals {
  hybrid_map_roles = [{
    rolearn  = var.account_b_node_role_arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes"]
  }]
}

resource "kubernetes_manifest" "aws_auth" {
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = { name = "aws-auth", namespace = "kube-system" }
    data     = { mapRoles = yamlencode(local.hybrid_map_roles) }
  }

  field_manager {
    name            = "terraform"
    force_conflicts = true
  }

  depends_on = [module.eks, time_sleep.wait_eks_propagation]
}
