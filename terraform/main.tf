terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.70.0"
    }
  }

  backend "s3" {
    bucket                  = "terraform-state-bucket-demo-api"
    key                     = "state/terraform.tfstate"
    region                  = "eu-central-1"
    encrypt                 = true
    kms_key_id              = "alias/terraform-bucket-key"
    dynamodb_table          = "terraform-state"
    shared_credentials_file = "$HOME/.aws/credentials"
    profile                 = "admin-ec2-deployment-demo"
  }
}

provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "admin-ec2-deployment-demo"
}

