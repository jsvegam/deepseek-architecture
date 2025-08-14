# Read the cluster after it’s created
data "aws_eks_cluster" "eks" {
  provider   = aws.virginia
  name       = var.eks_cluster_name
  depends_on = [module.eks, time_sleep.wait_eks_propagation]
}

# Usa el endpoint/CA que exporta tu wrapper (module.eks)
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # Auth vía AWS CLI con tu perfil de la cuenta dueña del cluster (Virginia)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", var.eks_cluster_name,   # Debe coincidir EXACTO con el nombre creado
      "--region", "us-east-1",
      "--profile", "jsvegam.aws.data"
    ]
  }
}
