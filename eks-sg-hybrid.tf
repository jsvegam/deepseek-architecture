# Añade reglas directamente al SG del cluster creado por el módulo EKS.
resource "aws_security_group_rule" "api_from_remote_nodes" {
  type              = "ingress"
  security_group_id = module.eks.cluster_security_group_id
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [var.remote_node_cidr]
  description       = "Allow EKS API from remote node CIDR (Hybrid Nodes)"
}

resource "aws_security_group_rule" "api_from_remote_pods" {
  type              = "ingress"
  security_group_id = module.eks.cluster_security_group_id
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [var.remote_pod_cidr]
  description       = "Allow EKS API from remote pod CIDR (Hybrid Nodes)"
}
