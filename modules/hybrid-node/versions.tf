terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 👇 allow the module to accept an additional alias from the parent
      configuration_aliases = [aws.eks_home]
    }
  }
}
