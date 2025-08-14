resource "aws_db_instance" "rds_postgres" {
  identifier              = "my-rds-postgres-${random_id.db_suffix.hex}"
  engine                  = "postgres"
  instance_class          = "db.t3.micro" # Cheapest RDS instance
  allocated_storage       = 20            # Minimum for PostgreSQL
  max_allocated_storage   = 50            # Enable storage autoscaling
  storage_type            = "gp2"
  username                = "dbadmin"        # Changed from reserved 'admin'
  password                = "SecurePass123!" # Use proper secrets
  skip_final_snapshot     = true             # For dev environments
  backup_retention_period = 0                # Reduce backup costs
}

# Add random suffix for unique resources
resource "random_id" "db_suffix" {
  byte_length = 4
}

# modules/rds/main.tf
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-${random_id.db_suffix.hex}" # Unique name
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}