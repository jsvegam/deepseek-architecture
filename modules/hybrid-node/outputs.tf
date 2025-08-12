output "activation_id" {
  value       = aws_ssm_activation.activation.id
  description = "SSM Activation ID"
}

output "activation_code" {
  value       = aws_ssm_activation.activation.activation_code
  description = "SSM Activation Code"
  sensitive   = true
}

output "instance_id" {
  value       = aws_instance.hybrid_node.id
  description = "EC2 instance ID of the hybrid node"
}

output "public_ip" {
  value       = aws_instance.hybrid_node.public_ip
  description = "Public IP (if assigned) for the hybrid node"
}

output "nodeadm_commands" {
  value = <<-EOT
# Install nodeadm (Ubuntu x86_64):
curl -OL 'https://hybrid-assets.eks.amazonaws.com/releases/latest/bin/linux/amd64/nodeadm' && \
chmod +x nodeadm && sudo mv nodeadm /usr/local/bin/

# Register via SSM Hybrid Activation (in ${var.hybrid_region}):
sudo nodeadm install \
  --provider ssm \
  --activation-id ${aws_ssm_activation.activation.id} \
  --activation-code ${aws_ssm_activation.activation.activation_code} \
  --region ${var.hybrid_region}

# Join your EKS control plane (in ${var.eks_cluster_region}):
sudo nodeadm join \
  --cluster-name ${var.eks_cluster_name} \
  --region ${var.eks_cluster_region} \
  --node-name $(hostname)
EOT
  description = "Commands to install and join the node as a hybrid worker"
}
