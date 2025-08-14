# # Nodo híbrido simulado en Ohio (us-east-2)


# # SG para la instancia que actuará como nodo híbrido
# resource "aws_security_group" "hybrid_node_ohio" {
#   provider    = aws.ohio
#   name        = "${var.eks_cluster_name}-hybrid-node-sg"
#   description = "SG para nodo híbrido en Ohio"
#   vpc_id      = module.vpc_ohio.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # (Opcional) SSH para pruebas. Restringe el CIDR en producción.
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.eks_cluster_name}-hybrid-node-sg"
#   }
# }

# # AMI Amazon Linux 2023 en Ohio
# data "aws_ssm_parameter" "al2023_ohio" {
#   provider = aws.ohio
#   name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
# }

# # Instancia EC2 que se registra como nodo híbrido en el EKS de Virginia
# resource "aws_instance" "hybrid_node_ohio" {
#   provider                    = aws.ohio
#   ami                         = data.aws_ssm_parameter.al2023_ohio.value
#   instance_type               = "t3.large"
#   subnet_id                   = module.vpc_ohio.public_subnets[0]
#   vpc_security_group_ids      = [aws_security_group.hybrid_node_ohio.id]
#   associate_public_ip_address = true
#   key_name                    = var.hybrid_ssh_key_name

#   user_data = <<-EOF
#     #!/usr/bin/env bash
#     set -euxo pipefail

#     dnf -y update || true
#     dnf -y install curl tar

#     # Descargar nodeadm
#     curl -fSL -o /usr/local/bin/nodeadm "https://hybrid-assets.eks.amazonaws.com/releases/latest/bin/linux/amd64/nodeadm"
#     chmod +x /usr/local/bin/nodeadm

#     # Instalar dependencias (kubelet, containerd, SSM) para la versión del cluster
#     nodeadm install ${module.eks.cluster_version} --credential-provider ssm

#     # Configuración para unirse al cluster EKS en us-east-1 usando la Activation de SSM
#     cat >/etc/nodeadm/nodeConfig.yaml <<NCFG
#     apiVersion: node.eks.aws/v1alpha1
#     kind: NodeConfig
#     spec:
#       cluster:
#         name: ${module.eks.cluster_name}
#         region: us-east-1
#       hybrid:
#         ssm:
#           activationCode: ${aws_ssm_activation.hybrid.activation_code}
#           activationId: ${aws_ssm_activation.hybrid.activation_id}
#     NCFG

#     # Registro del nodo
#     nodeadm init -c file:///etc/nodeadm/nodeConfig.yaml
#     systemctl enable --now kubelet
#   EOF

#   tags = {
#     Name = "${var.eks_cluster_name}-hybrid-ec2-ohio"
#   }
# }
