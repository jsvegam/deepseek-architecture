resource "local_file" "kubeconfig" {
  depends_on = [module.eks]
  filename   = "kubeconfig_${module.eks.cluster_id}"
  content = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_name    = module.eks.cluster_id
    endpoint        = module.eks.cluster_endpoint
    cluster_auth    = module.eks.cluster_certificate_authority_data
  })
}