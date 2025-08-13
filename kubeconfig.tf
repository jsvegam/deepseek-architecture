resource "local_file" "kubeconfig" {
  filename = "kubeconfig_${var.eks_cluster_name}"

  content = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name = var.eks_cluster_name
      cluster = {
        server                     = module.eks.cluster_endpoint
        certificate-authority-data = module.eks.cluster_certificate_authority_data
      }
    }]
    contexts = [{
      name = var.eks_cluster_name
      context = {
        cluster = var.eks_cluster_name
        user    = var.eks_cluster_name
      }
    }]
    "current-context" = var.eks_cluster_name
    users = [{
      name = var.eks_cluster_name
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1beta1"
          command    = "aws"
          args       = [
            "eks", "get-token",
            "--cluster-name", var.eks_cluster_name,
            "--region", "us-east-1",
            "--profile", "ACCOUNT_A_PROFILE"
          ]
        }
      }
    }]
  })
}
