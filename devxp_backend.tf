#Critical backend configuration for cloud infrastructure

resource "aws_s3_bucket" "terraform_backend_bucket" {
  bucket = "terraform-state-xll4dxd1nesgmp8k21rukrhcvkrhoflmsr8y9sfmecmrb"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
