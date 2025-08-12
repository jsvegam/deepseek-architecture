# outputs.tf (root)
output "hybrid_activation_id" {
  value       = module.hybrid_node_ohio.activation_id
  description = "SSM Activation ID (from hybrid-node module)"
}

output "hybrid_activation_code" {
  value       = module.hybrid_node_ohio.activation_code
  description = "SSM Activation Code (from hybrid-node module)"
  sensitive   = true
}

output "hybrid_nodeadm_commands" {
  value       = module.hybrid_node_ohio.nodeadm_commands
  description = "Run these on the EC2 to install & join"
}
