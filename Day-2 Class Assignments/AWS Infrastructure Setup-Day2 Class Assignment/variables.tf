variable "aws_region" {
  description = "Region where resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of EC2 key pair"
  type        = string
  default     = "day-two-syed_sofiyan-kp"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux"
  type        = string
  default     = "ami-0b09627181c8d5778"
}
