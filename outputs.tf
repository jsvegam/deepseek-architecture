# outputs.tf (root)
output "hybrid_activation_id" {
  value       = try(module.hybrid_node_ohio[0].activation_id, null)
  description = "SSM Activation ID for the hybrid node (Account B / Ohio)"
}

output "hybrid_activation_code" {
  value       = try(module.hybrid_node_ohio[0].activation_code, null)
  description = "SSM Activation Code for the hybrid node (Account B / Ohio)"
  sensitive   = true
}

output "hybrid_node_public_ip" {
  value       = try(module.hybrid_node_ohio[0].public_ip, null)
  description = "Public IP of the hybrid EC2 node"
}

output "hybrid_nodeadm_commands" {
  value       = try(module.hybrid_node_ohio[0].nodeadm_commands, null)
  description = "Commands to install and join the node as a hybrid worker"
}

