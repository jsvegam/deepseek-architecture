# Read the cluster after it’s created
data "aws_eks_cluster" "eks" {
  provider   = aws.virginia
  name       = var.eks_cluster_name
  depends_on = [module.eks, time_sleep.wait_eks_propagation]
}

# Single kubernetes provider in the whole repo
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", var.eks_cluster_name,
      "--region", "us-east-1",
      "--profile", "jsvegam.aws.data"
    ]
  }
}
