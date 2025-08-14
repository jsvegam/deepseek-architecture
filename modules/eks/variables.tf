# Entradas desde el root module (tu main.tf)

variable "cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versión menor de Kubernetes (1.29/1.30/1.31)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID del cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets del cluster (normalmente privadas)"
  type        = list(string)
}

variable "authentication_mode" {
  description = "Modo de autenticación (API, CONFIG_MAP o API_AND_CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "cluster_endpoint_public_access" {
  description = "Habilita endpoint público"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Habilita endpoint privado"
  type        = bool
  default     = false
}

variable "remote_node_cidr" {
  description = "CIDR de la red donde viven los nodos híbridos"
  type        = string
}

variable "remote_pod_cidr" {
  description = "CIDR de los pods que correrán en nodos híbridos"
  type        = string
}

variable "cluster_admin_principal_arn" {
  description = "ARN del principal admin del cluster (rol/usuario IAM)"
  type        = string
}

variable "desired_size" {
  type        = number
  description = "Tamaño deseado del node group"
}

variable "min_size" {
  type        = number
  description = "Tamaño mínimo del node group"
}

variable "max_size" {
  type        = number
  description = "Tamaño máximo del node group"
}

variable "instance_types" {
  type        = list(string)
  description = "Tipos de instancia del node group"
}

variable "capacity_type" {
  type        = string
  description = "SPOT u ON_DEMAND"
}

variable "disk_size" {
  type        = number
  description = "Tamaño de disco por nodo (GiB)"
}

variable "tags" {
  description = "Etiquetas comunes"
  type        = map(string)
  default     = {}
}


variable "managed_node_ami_id" {
  description = "AMI ID para el EKS managed node group (evita consulta SSM)"
  type        = string
  default     = null
}
