terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "sofiyan_s3_bucket" {
  bucket = "minfy-training-sofiyan-s3-20250612"
  force_destroy = true
  tags = {
    Name = "My First Terraform Bucket"
  }
}
