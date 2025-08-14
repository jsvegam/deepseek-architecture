#############################################
# main.tf — EKS en Virginia con Hybrid Nodes
#############################################

# ================
# VPC Virginia (Account A)
# ================
module "vpc_virginia" {
  source    = "terraform-aws-modules/vpc/aws"
  version   = "5.0.0"
  providers = { aws = aws.virginia }

  name = "vpc-virginia"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # IMPORTANTE: usar el nombre real del cluster
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# ======================================
# CIDRs remotos para Hybrid Nodes
# ======================================
locals {
  remote_node_cidr = var.remote_node_cidr
  remote_pod_cidr  = var.remote_pod_cidr
}

# =========================
# AMI de EKS (AL2023 x86_64) para K8s 1.29 — SIN SSM
# =========================
data "aws_ami" "eks_al2023_129" {
  provider    = aws.virginia
  most_recent = true
  owners      = ["602401143452"] # Cuenta oficial de AMIs de EKS

  filter {
    name   = "name"
    values = [
      "amazon-eks-node-al2023-x86_64-standard-1.29-*",
      "amazon-eks-1.29-al2023-x86_64-*"
    ]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =========================
# Módulo EKS (wrapper v21) — con Hybrid Nodes
# =========================
module "eks" {
  source    = "./modules/eks"
  providers = { aws = aws.virginia }

  # wrapper vars -> módulo oficial v21 (name/kubernetes_version)
  cluster_name       = var.eks_cluster_name
  kubernetes_version = "1.29"

  vpc_id     = module.vpc_virginia.vpc_id
  subnet_ids = module.vpc_virginia.private_subnets
  # TIP (debug inicial): podrías usar públicas temporalmente
  # subnet_ids = module.vpc_virginia.public_subnets

  # Node group administrado
  desired_size   = 1
  min_size       = 1
  max_size       = 1

  # 👉 cambios solicitados
  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small", "t3a.small", "t3.medium", "t3a.medium", "t2.small"]
  disk_size      = 20

  # Evitar SSM en el node group: fija la AMI explícita
  managed_node_ami_id = data.aws_ami.eks_al2023_129.id

  # Endpoint público (lab) y auth moderna (Access Entries)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  authentication_mode             = "API_AND_CONFIG_MAP"


  # Hybrid: redes remotas de nodos y pods
  remote_node_cidr = local.remote_node_cidr
  remote_pod_cidr  = local.remote_pod_cidr

  # Admin del cluster (lo asocias luego con aws_eks_access_* en eks-access.tf)
  cluster_admin_principal_arn = var.cluster_admin_principal_arn

  tags = { Environment = "production" }
}

# ==================================
# Espera para la propagación del cluster
# ==================================
resource "time_sleep" "wait_eks_propagation" {
  depends_on      = [module.eks]
  create_duration = "90s"
}
