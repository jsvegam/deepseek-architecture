terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

# Wrapper del módulo oficial EKS v21
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  authentication_mode = var.authentication_mode

  # Evita el admin por defecto (que usa system:masters)
  enable_cluster_creator_admin_permissions = false

  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access

  # Hybrid networking (si aplicara)
  remote_network_config = {
    remote_node_networks = { cidrs = [var.remote_node_cidr] }
    remote_pod_networks  = { cidrs = [var.remote_pod_cidr] }
  }

  # Access entry admin con CAM Policy
  access_entries = {
    admin = {
      principal_arn = var.cluster_admin_principal_arn
      type          = "STANDARD"
      access_policy_associations = {
        cluster_admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  # Managed Node Group
  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = var.instance_types
      capacity_type  = var.capacity_type
      disk_size      = var.disk_size

      ami_type = "AL2023_x86_64_STANDARD"
      ami_id   = var.managed_node_ami_id
    }
  }

  tags = var.tags
}
