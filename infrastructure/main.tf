terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# SSM params for Basic Auth defaults (avoid storing in TF state, but for demo we use simple strings)
module "ssm" {
  source = "./ssm"
}
