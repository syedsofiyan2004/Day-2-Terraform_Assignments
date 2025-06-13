terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }

  backend "s3" {
    bucket="sofiyan-terraform-state-20250612"
    key="assignment-01/terraform.tfstate"
    region="ap-south-1"
  }
}
