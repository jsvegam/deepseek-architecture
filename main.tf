############################################
# VPC en VIRGINIA (Account A / us-east-1)
############################################
module "vpc_virginia" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  providers = {
    aws = aws.virginia
  }

  name = "vpc-virginia"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  # enable_dns_support   = true  # (por defecto es true; descomenta si lo deseas explícito)

  # Etiquetas necesarias para LoadBalancers internos (privadas)
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/my-eks-cluster"    = "shared"
  }

  # Etiquetas necesarias para LoadBalancers públicos (públicas)
  public_subnet_tags = {
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/my-eks-cluster"    = "shared"
  }
}

############################################
# EKS (Account A / us-east-1)
############################################
module "eks" {
  source = "./modules/eks"
  providers = {
    aws = aws.virginia
  }

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc_virginia.vpc_id
  subnet_ids = module.vpc_virginia.private_subnets

  # Node group configuration
  desired_size   = 2
  max_size       = 3
  min_size       = 1
  instance_types = ["t3.small"]
  capacity_type  = "SPOT"
  disk_size      = 20

  tags = {
    Environment = "production"
  }
}

############################################
# Espera de propagación del EKS (evita carreras)
# Requiere provider "time" en providers.tf
############################################
resource "time_sleep" "wait_eks_propagation" {
  depends_on      = [module.eks]
  create_duration = "90s" # ajusta a 120-180s si lo necesitas
}

############################################
# VPC en OHIO (Account B / us-east-2)
############################################
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

############################################
# Hybrid Node (Account B + Account A)
############################################
module "hybrid_node_ohio" {
  count  = var.enable_hybrid ? 1 : 0
  source = "./modules/hybrid-node"

  providers = {
    aws          = aws.ohio      # EC2/SSM/IAM en Account B (Ohio)
    aws.eks_home = aws.virginia  # EKS en Account A (Virginia)
  }

  eks_cluster_name    = var.eks_cluster_name
  eks_cluster_region  = "us-east-1"

  hybrid_region       = "us-east-2"
  hybrid_vpc_id       = module.vpc_ohio.vpc_id
  hybrid_subnet_id    = module.vpc_ohio.private_subnets[0]

  instance_type       = "t3.small"
  key_name            = null

  # 👇 desactivar Access Entry (requisito “misma cuenta”).
  create_access_entry = false

  tags = {
    Project = "deepseek"
    Env     = "lab"
  }
}


############################################
# (Opcionales) Otros módulos, comentados
############################################
# module "msk" {
#   source = "./modules/msk"
#   providers = { aws = aws.ohio }
#   vpc_id          = module.vpc_ohio.vpc_id
#   private_subnets = module.vpc_ohio.private_subnets
# }

# module "glue_schema" {
#   source    = "./modules/glue_schema"
#   providers = { aws = aws.ohio }
# }

# module "s3" {
#   source    = "./modules/s3"
#   providers = { aws = aws.virginia }
#   bucket_name = "jsvegam2025"
#   vpc_id      = module.vpc_virginia.vpc_id
# }

# module "rds" {
#   source    = "./modules/rds"
#   providers = { aws = aws.virginia }
#   vpc_id          = module.vpc_virginia.vpc_id
#   private_subnets = module.vpc_virginia.private_subnets
# }

############################################
# Outputs
############################################
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

############################################
# ECR (en Virginia) – opcional
############################################
module "ecr" {
  providers = {
    aws = aws.virginia
  }
  source    = "./modules/ecr"
  repo_name = "deepseek-app"
  # Sugerencia: si vas a destruir a menudo, agrega force_delete=true dentro del módulo ecr
}
