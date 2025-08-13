# VPC Virginia (Account A)
module "vpc_virginia" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  providers = { aws = aws.virginia }

  name = "vpc-virginia"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/mi-cluster" = "shared" # Changed to match your cluster name
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/mi-cluster" = "shared" # Changed to match your cluster name
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  providers = { aws = aws.virginia } # Added provider

  cluster_name    = "mi-cluster"
  cluster_version = "1.27"
  vpc_id          = module.vpc_virginia.vpc_id # Changed from module.vpc to module.vpc_virginia
  subnet_ids      = module.vpc_virginia.private_subnets # Changed from module.vpc to module.vpc_virginia

  # Configuración esencial de node groups
  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 20
      
      # Configuración de IAM para los nodos
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  # Configuración de addons recomendados
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      preserve = true
    }
    kube-proxy = {}
    vpc-cni = {
      preserve = true
    }
  }

  # Configuración de acceso
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  tags = {
    Environment = "production"
  }
}

# Espera para la propagación del cluster
resource "time_sleep" "wait_eks_propagation" { # Changed from wait_for_cluster to match your dependencies
  depends_on      = [module.eks]
  create_duration = "90s"
}

# VPC Ohio (Account B)
module "vpc_ohio" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  providers = { aws = aws.ohio }

  name = "vpc-ohio"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# Hybrid node (Account B / Ohio) — no AccessEntry (cross-account)
module "hybrid_node_ohio" {
  count      = var.enable_hybrid ? 1 : 0
  source     = "./modules/hybrid-node"
  depends_on = [time_sleep.wait_eks_propagation]

  providers = {
    aws          = aws.ohio
    aws.eks_home = aws.virginia
  }

  eks_cluster_name    = "mi-cluster" # Changed from var.eks_cluster_name to match your cluster name
  eks_cluster_region  = "us-east-1"
  hybrid_region       = "us-east-2"
  hybrid_vpc_id       = module.vpc_ohio.vpc_id
  hybrid_subnet_id    = module.vpc_ohio.private_subnets[0]

  instance_type       = "t3.small"
  key_name            = null
  create_access_entry = false  # <- required for cross-account

  tags = { Project = "deepseek", Env = "lab" }
}

# ECR (Virginia) — suggest force_delete in module
module "ecr" {
  source    = "./modules/ecr"
  providers = { aws = aws.virginia }
  repo_name = "deepseek-app"
}

output "eks_cluster_endpoint"                 { value = module.eks.cluster_endpoint }
output "eks_cluster_ca_certificate"           { value = module.eks.cluster_certificate_authority_data }