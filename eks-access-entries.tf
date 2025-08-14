# Confianza: SSM asume este rol en instancias híbridas (Managed Instances)
data "aws_iam_policy_document" "hybrid_nodes_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

# Rol que usará la Activation SSM para el nodo híbrido
resource "aws_iam_role" "hybrid_nodes" {
  name               = "${var.eks_cluster_name}-hybrid-nodes"
  assume_role_policy = data.aws_iam_policy_document.hybrid_nodes_trust.json
  tags               = var.tags
}

# Adjunta políticas mínimas recomendadas
resource "aws_iam_role_policy_attachment" "hybrid_ssm_core" {
  role       = aws_iam_role.hybrid_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "hybrid_eks_worker" {
  role       = aws_iam_role.hybrid_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "hybrid_ecr_ro" {
  role       = aws_iam_role.hybrid_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Activation SSM (entrega ActivationId/Code para nodeadm)
resource "aws_ssm_activation" "hybrid" {
  name               = "${var.eks_cluster_name}-hybrid-activation"
  description        = "Hybrid activation for EKS hybrid node(s)"
  iam_role           = aws_iam_role.hybrid_nodes.name
  registration_limit = var.hybrid_registration_limit
  tags               = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.hybrid_ssm_core
  ]
}

# Access Entry para que el kubelet híbrido se autentique en el cluster
resource "aws_eks_access_entry" "hybrid_nodes" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.hybrid_nodes.arn
  type          = "HYBRID_LINUX"

  depends_on = [module.eks]
}


# Give the CURRENT console principal cluster-admin on this EKS cluster
resource "aws_eks_access_entry" "console_admin_access_entry" {
  provider      = aws.virginia
  cluster_name  = module.eks.cluster_name
  principal_arn = var.current_console_principal_arn
  type          = "STANDARD"

  depends_on = [
    module.eks,
    time_sleep.wait_eks_propagation
  ]
}

resource "aws_eks_access_policy_association" "console_admin_policy_assoc" {
  provider      = aws.virginia
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.console_admin_access_entry.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.console_admin_access_entry]
}
