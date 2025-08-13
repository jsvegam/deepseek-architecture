module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.11"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  eks_managed_node_groups = {
    nodes = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      disk_size      = var.disk_size
      instance_types = var.instance_types
      capacity_type  = var.capacity_type
      ami_type       = "AL2023_x86_64_STANDARD"
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP"
  enable_irsa         = true

  # 👇 Grant your IAM principal cluster-admin via EKS Access Entries
  access_entries = {
    admin = {
      principal_arn = var.cluster_admin_principal_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns    = { preserve = true }
    kube-proxy = {}
    vpc-cni    = { preserve = true, most_recent = true }
  }

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  tags = var.tags
}
