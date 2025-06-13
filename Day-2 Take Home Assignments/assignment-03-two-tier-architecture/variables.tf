 variable "aws_region" {
  default="ap-south-1"
}

variable "instance_type" {
  default="t2.micro"
}

variable "ami_id" {
  description="AMI ID for Web Server"
}

variable "db_username" {
  default="admin"
}

variable "db_password" {
  type=string
  sensitive=true
}

variable "key_name" {
  type = string
}