output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "hybrid_vpc_id" {
  value = aws_vpc.hybrid.id
}

output "hybrid_node_public_ip" {
  value = aws_instance.hybrid_node.public_ip
}
