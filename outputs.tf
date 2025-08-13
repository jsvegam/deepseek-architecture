
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "vpc_virginia_id" {
  value = module.vpc_virginia.vpc_id
}

output "vpc_ohio_id" {
  value = module.vpc_ohio.vpc_id
}