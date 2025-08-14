variable "eks_cluster_name" {
  description = "Nombre del cluster EKS."
  type        = string
  default     = "deepseek-eks"
}

variable "kubernetes_version" {
  description = "Versión menor de Kubernetes usada por EKS y nodeadm."
  type        = string
  default     = "1.29"
}

variable "remote_node_cidr" {
  description = "CIDR de red de los nodos híbridos (si aplica)."
  type        = string
  default     = "10.99.1.0/24"
}

variable "remote_pod_cidr" {
  description = "CIDR de pods remotos (si aplica)."
  type        = string
  default     = "10.200.0.0/16"
}

variable "cluster_admin_principal_arn" {
  description = "ARN del rol/usuario que será admin del clúster (NO root)."
  type        = string
}

variable "current_console_principal_arn" {
  description = "ARN del rol/usuario con el que entras a la consola (NO root)."
  type        = string
}

variable "hybrid_instance_type" {
  description = "Tipo de instancia para el nodo híbrido."
  type        = string
  default     = "t3.large"
}

variable "hybrid_ssh_key_name" {
  description = "Nombre del KeyPair SSH (opcional)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags comunes."
  type        = map(string)
  default = {
    Project = "deepseek-architecture"
    Env     = "lab"
  }
}
