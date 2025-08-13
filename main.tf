

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
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/mi-cluster" = "shared"
  }
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/mi-cluster" = "shared"
  }
}

# Módulo EKS (versión actualizada)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3" # Versión específica probada
  providers = { aws = aws.virginia }

  cluster_name    = "mi-cluster"
  cluster_version = "1.27"
  vpc_id          = module.vpc_virginia.vpc_id
  subnet_ids      = module.vpc_virginia.private_subnets

  # Configuración para evitar la gestión automática de aws-auth
  manage_aws_auth_configmap = false # Argumento correcto

  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 20
      
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

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

  tags = {
    Environment = "production"
  }
}

# Espera para la propagación del cluster
resource "time_sleep" "wait_eks_propagation" {
  depends_on      = [module.eks]
  create_duration = "90s"
}