# IMPORTANTE:
# - El VPC CNI de AWS NO es compatible con Hybrid Nodes.
# - Instala Calico (o Cilium) para dar IP a pods en nodos híbridos.
# - Aquí configuramos Calico con un pool que coincide con var.remote_pod_cidr.

resource "helm_release" "calico" {
  name             = "calico"
  repository       = "https://docs.tigera.io/calico/charts"
  chart            = "tigera-operator"
  namespace        = "tigera-operator"
  create_namespace = true

  # Ajusta versión si quieres fijarla, p.ej.:
  # version = "v3.30.2"

  values = [
    yamlencode({
      installation = {
        kubernetesProvider = "EKS"
        cni = {
          type = "Calico"
        }
        calicoNetwork = {
          ipPools = [{
            cidr          = var.remote_pod_cidr
            encapsulation = "VXLAN"
          }]
        }
      }
    })
  ]

  depends_on = [module.eks]
}
