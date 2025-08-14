# hybrid-ec2-node.tf — ONLY SG + EC2 + bootstrap
# Requires hybrid-vpc.tf to have created:
#   - aws_vpc.hybrid
#   - aws_subnet.hybrid_a
# And eks-access-entries.tf to have created:
#   - aws_ssm_activation.hybrid

# AMI Amazon Linux 2023 (no SSM)
data "aws_ami" "al2023_amd64" {
  provider    = aws.virginia
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for the hybrid node (egress all; SSH optional for lab)
resource "aws_security_group" "hybrid_node" {
  provider    = aws.virginia
  name        = "${var.eks_cluster_name}-hybrid-node-sg"
  description = "SG for hybrid node (lab)"
  vpc_id      = aws_vpc.hybrid.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional SSH (prefer SSM Session Manager in prod)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# EC2 instance acting as a hybrid node
resource "aws_instance" "hybrid_node" {
  provider                    = aws.virginia
  ami                         = data.aws_ami.al2023_amd64.id
  instance_type               = var.hybrid_instance_type
  subnet_id                   = aws_subnet.hybrid_a.id
  vpc_security_group_ids      = [aws_security_group.hybrid_node.id]
  key_name                    = var.hybrid_ssh_key_name
  associate_public_ip_address = true

  # Recreate instance if user_data changes
  user_data_replace_on_change = true

  # Bootstrap: install nodeadm, configure NodeConfig (SSM Activation), register kubelet
  user_data = <<-EOF
    #!/usr/bin/env bash
    set -euxo pipefail

    dnf -y update || true
    dnf -y install curl tar

    # Download nodeadm
    curl -fSL -o /usr/local/bin/nodeadm "https://hybrid-assets.eks.amazonaws.com/releases/latest/bin/linux/amd64/nodeadm"
    chmod +x /usr/local/bin/nodeadm

    # Install deps (kubelet, containerd, SSM) for K8s ${var.kubernetes_version}
    nodeadm install ${var.kubernetes_version} --credential-provider ssm

    # NodeConfig with SSM Activation and cluster info
    cat >/etc/nodeadm/nodeConfig.yaml <<NCFG
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      cluster:
        name: ${var.eks_cluster_name}
        region: ${var.aws_region}
      hybrid:
        ssm:
          activationCode: ${aws_ssm_activation.hybrid.activation_code}
          activationId: ${aws_ssm_activation.hybrid.id}
    NCFG

    # Register the node
    nodeadm init -c file:///etc/nodeadm/nodeConfig.yaml
    systemctl enable --now kubelet
  EOF

  tags = merge(var.tags, { Name = "${var.eks_cluster_name}-hybrid-ec2" })
}
