# Access entry para tu principal de consola (NO root)
resource "aws_eks_access_entry" "console_admin_access_entry" {
  provider      = aws.virginia
  cluster_name  = module.eks.cluster_name
  principal_arn = var.current_console_principal_arn
  type          = "STANDARD"

  depends_on = [module.eks, time_sleep.wait_eks_propagation]
}

resource "aws_eks_access_policy_association" "console_admin_policy_assoc" {
  provider      = aws.virginia
  cluster_name  = module.eks.cluster_name
  principal_arn = var.current_console_principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.console_admin_access_entry]
}

# (Opcional) Activación SSM para nodeadm del híbrido
resource "aws_iam_role" "hybrid_nodes" {
  name = "${var.eks_cluster_name}-hybrid-nodes"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ssm.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_ssm_activation" "hybrid" {
  name               = "${var.eks_cluster_name}-hybrid-activation"
  description        = "Hybrid activation for EKS hybrid node(s)"
  iam_role           = aws_iam_role.hybrid_nodes.name
  registration_limit = 1
  tags               = var.tags
}
