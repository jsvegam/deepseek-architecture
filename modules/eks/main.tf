module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.11"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  # <<< REEMPLAZA todo tu bloque eks_managed_node_groups por este >>>
  eks_managed_node_groups = {
    nodes = {
      name           = "nodes"                       # nombre fijo y predecible
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      capacity_type  = "ON_DEMAND"                   # evita problemas de capacidad al inicio
      instance_types = ["t3.small","t3a.small","t2.small"]
      ami_type       = "AL2023_x86_64_STANDARD"      # EKS 1.29/1.30 (ajusta si usas otra versión/arquitectura)
      disk_size      = var.disk_size
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP"
  access_entries      = {}
  enable_irsa         = true

  cluster_addons = {
    coredns    = { preserve = true }
    kube-proxy = {}
    vpc-cni    = { preserve = true, most_recent = true }
  }

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  tags = var.tags
}
