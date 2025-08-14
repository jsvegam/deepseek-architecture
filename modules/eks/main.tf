terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

# Wrapper al módulo oficial
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # === nombres v21 ===
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Autenticación (Access Entries / CAM)
  authentication_mode = var.authentication_mode

  # Evita que el módulo cree un admin por defecto (evita system:masters)
  enable_cluster_creator_admin_permissions = false

  # === endpoint flags v21 ===
  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access

  # Hybrid Nodes (nombre v21 sin "cluster_")
  remote_network_config = {
    remote_node_networks = { cidrs = [var.remote_node_cidr] }
    remote_pod_networks  = { cidrs = [var.remote_pod_cidr] }
  }

  # Access entries (admin) — usa Access Policy en vez de kubernetes_groups
  access_entries = {
    admin = {
      principal_arn = var.cluster_admin_principal_arn
      type          = "STANDARD"

      access_policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Node group administrado
  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = var.instance_types
      capacity_type  = var.capacity_type
      disk_size      = var.disk_size

      # Evita SSM: define tipo y AMI explícita
      ami_type = "AL2023_x86_64_STANDARD"
      ami_id   = var.managed_node_ami_id
    }
  }

  tags = var.tags
}
