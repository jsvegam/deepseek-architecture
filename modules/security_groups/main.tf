resource "aws_security_group" "msk" {
  vpc_id = var.vpc_id
  # Add MSK-specific rules
}

resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_sg_id]
  }
}