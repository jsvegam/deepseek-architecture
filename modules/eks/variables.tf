variable "cluster_name" {
  description = "Nombre del clúster EKS."
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para el clúster (p. ej. 1.29)."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde vive el clúster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets donde se desplegarán los nodos/ENIs del clúster."
  type        = list(string)
}

variable "authentication_mode" {
  description = "Modo de autenticación de EKS (recomendado: API_AND_CONFIG_MAP)."
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Si el endpoint del API server es accesible públicamente."
  type        = bool
}

variable "cluster_endpoint_private_access" {
  description = "Si el endpoint del API server es accesible privadamente por la VPC."
  type        = bool
}

variable "remote_node_cidr" {
  description = "CIDR de los nodos remotos (Hybrid Nodes) si aplica."
  type        = string
}

variable "remote_pod_cidr" {
  description = "CIDR de los pods remotos (Hybrid Nodes) si aplica."
  type        = string
}

variable "cluster_admin_principal_arn" {
  description = "ARN del principal (user/role) que tendrá permisos de admin vía CAM."
  type        = string
}

variable "desired_size" {
  description = "Tamaño deseado del Managed Node Group."
  type        = number
}

variable "min_size" {
  description = "Tamaño mínimo del Managed Node Group."
  type        = number
}

variable "max_size" {
  description = "Tamaño máximo del Managed Node Group."
  type        = number
}

variable "instance_types" {
  description = "Tipos de instancia para el Managed Node Group."
  type        = list(string)
}

variable "capacity_type" {
  description = "Tipo de capacidad del Node Group (ON_DEMAND o SPOT)."
  type        = string
}

variable "disk_size" {
  description = "Tamaño de disco (GiB) para los nodos del Node Group."
  type        = number
}

variable "managed_node_ami_id" {
  description = "AMI explícita para el Node Group (EKS-Optimized AL2023 para tu versión)."
  type        = string
}

variable "tags" {
  description = "Tags comunes a aplicar."
  type        = map(string)
}
