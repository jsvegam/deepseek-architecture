variable "aws_region" {
  description = "Región para el cluster EKS (Virginia)."
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  description = "Nombre del cluster EKS."
  type        = string
  default     = "deepseek-eks"
}

# Úsala si algún script/archivo la requiere. En tu main.tf la versión del cluster la defines ahí.
variable "kubernetes_version" {
  description = "Versión menor de Kubernetes para EKS (para nodeadm/cni si lo usas)."
  type        = string
  default     = "1.29"
}

# Endpoint flags (opcionales; si no los consumes en main.tf, igual no pasa nada)
variable "cluster_endpoint_public_access" {
  description = "Expose EKS API públicamente (útil para pruebas con nodo híbrido en otra VPC)."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Acceso privado al endpoint del API server."
  type        = bool
  default     = false
}

# Admin del cluster (obligatoria)
variable "cluster_admin_principal_arn" {
  description = "ARN del principal administrador del cluster (IAM user/role)."
  type        = string
}

# Redes remotas para Hybrid Nodes
variable "remote_node_cidr" {
  description = "CIDR de las IPs de tus nodos híbridos (lado remoto/otra VPC)."
  type        = string
  default     = "10.99.1.0/24"
}

variable "remote_pod_cidr" {
  description = "CIDR de los Pods que correrán en nodos híbridos (Calico/Cilium IPAM)."
  type        = string
  default     = "10.200.0.0/16"
}

# Etiquetas comunes
variable "tags" {
  description = "Etiquetas comunes."
  type        = map(string)
  default = {
    Project = "deepseek-architecture"
    Env     = "lab"
  }
}

# Híbrido (EC2 simulado)
variable "hybrid_instance_type" {
  description = "Tipo de instancia EC2 para simular el nodo híbrido."
  type        = string
  default     = "t3.large"
}

variable "hybrid_ssh_key_name" {
  description = "Nombre del KeyPair para acceso SSH a la instancia híbrida (opcional)."
  type        = string
  default     = null
}

variable "hybrid_registration_limit" {
  description = "Máximo de registros para la Activación SSM."
  type        = number
  default     = 1
}

variable "hybrid_vpc_cidr" {
  description = "CIDR de la VPC donde vive la EC2 'híbrida'."
  type        = string
  default     = "10.99.0.0/16"
}

# Si haces peering y necesitas anunciar al otro lado, pasa las route tables del cluster
variable "eks_private_route_table_ids" {
  description = "Route tables privadas de la VPC de EKS para anunciar el CIDR remoto."
  type        = list(string)
  default     = []
}

# (Opcional) Solo para silenciar warning si lo tienes en terraform.auto.tfvars
variable "account_b_node_role_arn" {
  description = "ARN de rol de otra cuenta (no usado actualmente)."
  type        = string
  default     = null
}


variable "manage_aws_auth_configmap" {
  description = "Si true, gestiona el ConfigMap aws-auth (no necesario con Access Entries)."
  type        = bool
  default     = false
}

variable "current_console_principal_arn" {
  description = "ARN of the IAM user/role you're logged into the AWS Console with."
  type        = string
}


