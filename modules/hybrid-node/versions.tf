terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # allow parent to pass an extra alias for EKS control-plane region/account
      configuration_aliases = [aws.eks_home]
    }
  }
}
