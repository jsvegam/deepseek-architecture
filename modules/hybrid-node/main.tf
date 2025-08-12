# modules/hybrid-node/main.tf
#
# This module expects TWO provider configs passed from root:
#   - aws          → region for EC2/SSM (e.g., us-east-2 / Ohio)
#   - aws.eks_home → region where your EKS control plane lives (e.g., us-east-1 / Virginia)

# -------- IAM for EC2 (Session Manager on the instance) --------

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

# -------- "On-prem" SSM role + Hybrid Activation (used by nodeadm install) --------

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
  iam_role           = aws_iam_role.hybrid_onprem_role.name   # must trust ssm.amazonaws.com
  registration_limit = var.ssm_registration_limit
  depends_on         = [aws_iam_role_policy_attachment.hybrid_onprem_ssm_core]
}

# -------- Networking + EC2 (hybrid node host) --------

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
# SSM agent is preinstalled on many Ubuntu AMIs; if not, you could install/enable it here.
EOF
}

# -------- OPTIONAL: EKS Access Entry in control-plane region --------
# These must run with the EKS control-plane provider alias: aws.eks_home

data "aws_partition" "current" {}

resource "aws_eks_access_entry" "hybrid_role_entry" {
  count         = var.create_access_entry ? 1 : 0
  provider      = aws.eks_home
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.hybrid_ec2_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "hybrid_node_policy" {
  count         = var.create_access_entry ? 1 : 0
  provider      = aws.eks_home
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.hybrid_ec2_role.arn
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSWorkerNodePolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.hybrid_role_entry]
}
