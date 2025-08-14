terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"   # quédate en v5
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"   # kubernetes_manifest estable
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}

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


