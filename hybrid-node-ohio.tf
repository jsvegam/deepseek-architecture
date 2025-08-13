variable "enable_hybrid" {
  type    = bool
  default = true
}

module "hybrid_node_ohio" {
  count      = var.enable_hybrid ? 1 : 0
  source     = "./modules/hybrid-node"
  depends_on = [kubernetes_config_map_v1.aws_auth]

  providers = {
    aws          = aws.ohio
    aws.eks_home = aws.virginia
  }

  eks_cluster_name    = "mi-cluster"
  eks_cluster_region  = "us-east-1"
  hybrid_region       = "us-east-2"
  hybrid_vpc_id       = module.vpc_ohio.vpc_id
  hybrid_subnet_id    = module.vpc_ohio.private_subnets[0]
  instance_type       = "t3.small"
  key_name            = null
  create_access_entry = false

  tags = { Project = "deepseek", Env = "lab" }
}