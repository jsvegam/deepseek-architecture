# Compatibles con lo que usan k8s-providers.tf y kubeconfig.tf
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

# Extras útiles
output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubernetes_version" {
  value = module.eks.cluster_version
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
