terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

# Default (opcional). Útil si tienes recursos sin alias.
provider "aws" {
  region = var.aws_region # "us-east-1" por defecto en tu variables.tf
  # profile     = "tu-perfil"          # <- si usas credenciales por perfil
  # assume_role { role_arn = "arn:aws:iam::<acct>:role/Role" }  # <- si es cross-account
}

# Alias para Virginia (us-east-1) — requerido por:
# providers = { aws = aws.virginia } en tus módulos
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
  # profile     = "tu-perfil-virginia"
  # assume_role { role_arn = "arn:aws:iam::<acct-A>:role/RoleVirginia" }
}

# Alias para Ohio (us-east-2) — SOLO si usas archivos/mods en Ohio
# (si dejaste Ohio comentado puedes omitir este bloque)
provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
  # profile     = "tu-perfil-ohio"
  # assume_role { role_arn = "arn:aws:iam::<acct-B>:role/RoleOhio" }
}
