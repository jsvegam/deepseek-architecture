# modules/hybrid-node/main.tf
# Proveedores esperados desde el root:
#   aws          -> Cuenta B, us-east-2 (EC2/SSM/IAM del nodo)
#   aws.eks_home -> Cuenta A, us-east-1 (control plane de EKS)

############################################
# IAM para EC2 (Session Manager en la instancia) [Cuenta B]
############################################

data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cw_agent" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hybrid_ec2_role" {
  name               = "hybrid-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.hybrid_ec2_role.name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.hybrid_ec2_role.name
  policy_arn = data.aws_iam_policy.cw_agent.arn
}

resource "aws_iam_instance_profile" "hybrid_profile" {
  name = "hybrid-ec2-profile"
  role = aws_iam_role.hybrid_ec2_role.name
  tags = var.tags
}

############################################
# Rol "on-prem" para SSM + Activación híbrida [Cuenta B]
############################################

data "aws_iam_policy_document" "hybrid_onprem_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hybrid_onprem_role" {
  name               = "hybrid-ssm-onprem-role"
  assume_role_policy = data.aws_iam_policy_document.hybrid_onprem_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "hybrid_onprem_ssm_core" {
  role       = aws_iam_role.hybrid_onprem_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_ssm_activation" "activation" {
  name               = "hybrid-activation"
  description        = "Activation for EKS hybrid node lab"
  iam_role           = aws_iam_role.hybrid_onprem_role.name
  registration_limit = var.ssm_registration_limit
  depends_on         = [aws_iam_role_policy_attachment.hybrid_onprem_ssm_core]
}

############################################
# Networking + EC2 [Cuenta B]
############################################

resource "aws_security_group" "hybrid_sg" {
  name        = "hybrid-ec2-sg"
  description = "Allow egress for hybrid EC2"
  vpc_id      = var.hybrid_vpc_id
  tags        = var.tags

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "hybrid_node" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  subnet_id                   = var.hybrid_subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.hybrid_profile.name
  vpc_security_group_ids      = [aws_security_group.hybrid_sg.id]
  key_name                    = var.key_name
  tags                        = merge(var.tags, { Name = "hybrid-lab-node" })

  user_data = <<-EOF
#!/bin/bash
set -e
apt-get update -y
apt-get install -y curl jq
# Si ssm-agent no está, puedes instalarlo/activarlo aquí.
EOF
}

############################################
# Access Entry en el control plane [Cuenta A / us-east-1]
############################################

data "aws_partition" "current" {}

# Validamos que el cluster exista en el provider aws.eks_home
data "aws_eks_cluster" "home" {
  count    = var.create_access_entry ? 1 : 0
  provider = aws.eks_home
  name     = var.eks_cluster_name
}

# Para nodos híbridos no se asocian "access policies" (son para usuarios/roles STANDARD).
# Solo se crea el Access Entry con tipo de nodo.
resource "aws_eks_access_entry" "hybrid_role_entry" {
  count         = var.create_access_entry ? 1 : 0
  provider      = aws.eks_home
  cluster_name  = data.aws_eks_cluster.home[0].name
  principal_arn = aws_iam_role.hybrid_ec2_role.arn

  # Usa HYBRID_LINUX si tu provider lo soporta; si no, EC2_LINUX
  type = "HYBRID_LINUX"
  # type = "EC2_LINUX"
}

/*  No usar para nodos:
resource "aws_eks_access_policy_association" "hybrid_node_policy" {
  count = 0
}
*/
