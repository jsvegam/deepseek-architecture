terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

variable "aws_region" {
  description = "Región primaria (Virginia)."
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  alias  = "virginia"
  region = var.aws_region
  # profile = "default"  # opcional
}

provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
  # profile     = "tu-perfil-ohio"
  # assume_role { role_arn = "arn:aws:iam::<acct-B>:role/RoleOhio" }
}
