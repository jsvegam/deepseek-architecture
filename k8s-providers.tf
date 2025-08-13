# Lee los datos del cluster EKS en Virginia (Account A)
data "aws_eks_cluster" "eks" {
  provider  = aws.virginia
  name      = var.eks_cluster_name

  # Espera a que EKS esté listo antes de construir el provider kubernetes
  depends_on = [time_sleep.wait_eks_propagation]
}

# NOTA: no usamos data.aws_eks_cluster_auth aquí porque autenticaremos vía exec con perfil.

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

  # Autenticación con AWS CLI y tu perfil
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = [
      "eks", "get-token",
      "--cluster-name", var.eks_cluster_name,
      "--region", "us-east-1",
      "--profile", "jsvegam.aws.data"
    ]
  }
}
