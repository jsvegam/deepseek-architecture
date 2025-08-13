# providers.tf
provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "jsvegam.aws.data"
}

provider "aws" {
  alias   = "ohio"
  region  = "us-east-2"
  profile = "jsvegam"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"   # stay on latest v5; < 6.0.0
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}


