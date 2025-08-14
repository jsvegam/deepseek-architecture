#############################################
# hybrid-vpc.tf — VPC “hybrid” + peering EKS
#############################################

# VPC para simular “on-prem / red remota”
resource "aws_vpc" "hybrid" {
  cidr_block           = var.hybrid_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.eks_cluster_name}-hybrid" })
}

# Internet Gateway para la VPC hybrid
resource "aws_internet_gateway" "hybrid" {
  vpc_id = aws_vpc.hybrid.id
  tags   = var.tags
}

# Subnet para la instancia “nodo híbrido”
resource "aws_subnet" "hybrid_a" {
  vpc_id                  = aws_vpc.hybrid.id
  cidr_block              = cidrsubnet(var.hybrid_vpc_cidr, 8, 10) # /24 dentro del /16
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags                    = merge(var.tags, { Name = "${var.eks_cluster_name}-hybrid-a" })
}

# Route table pública de la VPC hybrid
resource "aws_route_table" "hybrid_public" {
  vpc_id = aws_vpc.hybrid.id
  tags   = var.tags
}

# Ruta a Internet
resource "aws_route" "hybrid_internet" {
  route_table_id         = aws_route_table.hybrid_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hybrid.id
}

# Asociación de la subnet con la RT pública
resource "aws_route_table_association" "hybrid_a" {
  subnet_id      = aws_subnet.hybrid_a.id
  route_table_id = aws_route_table.hybrid_public.id
}

# -----------------------------
# (Opcional) Peering con la VPC de EKS (Virginia)
# -----------------------------
resource "aws_vpc_peering_connection" "hybrid_to_eks" {
  vpc_id      = aws_vpc.hybrid.id
  peer_vpc_id = module.vpc_virginia.vpc_id
  auto_accept = true
  #peer_region = var.aws_region
  tags        = merge(var.tags, { Name = "${var.eks_cluster_name}-hybrid-peering" })
}

# En la VPC hybrid: ruta hacia el CIDR de la VPC de EKS
resource "aws_route" "hybrid_to_eks_vpc" {
  route_table_id            = aws_route_table.hybrid_public.id
  destination_cidr_block    = module.vpc_virginia.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.hybrid_to_eks.id
}

# En la VPC de EKS (Virginia): anunciar los CIDR remotos para nodos y pods
# Pasa las route tables privadas del cluster en var.eks_private_route_table_ids
resource "aws_route" "eks_to_hybrid_nodes" {
  for_each                  = toset(var.eks_private_route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.remote_node_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hybrid_to_eks.id
}

resource "aws_route" "eks_to_hybrid_pods" {
  for_each                  = toset(var.eks_private_route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.remote_pod_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hybrid_to_eks.id
}
