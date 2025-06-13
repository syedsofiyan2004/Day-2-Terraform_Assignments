terraform {
  backend "s3" {
    bucket = "minfy-training-sofiyan-s3-20250612"
    key    = "global/s3/terraform.tfstate"
    region = "ap-south-1"
  }
}
