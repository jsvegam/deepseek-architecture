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
  required_version = ">= 1.3.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4"
    }
  }
}
