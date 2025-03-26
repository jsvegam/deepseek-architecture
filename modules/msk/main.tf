resource "aws_security_group" "msk_sg" {
  name        = "msk-security-group"
  description = "Security group for MSK cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"] # Adjust to your VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = "my-msk-cluster"
  kafka_version          = "3.4.0"
  number_of_broker_nodes = 3  # Must match AZ count (3 AZs → 3 brokers)

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = var.private_subnets
    security_groups = [aws_security_group.msk_sg.id]

    storage_info {
      ebs_storage_info {
        volume_size = 10  # Minimum size
      }
    }
  }
}