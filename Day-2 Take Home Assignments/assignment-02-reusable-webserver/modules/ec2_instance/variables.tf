 variable "instance_type" {
  type=string
}

variable "ami_id" {
  type=string
}

variable "subnet_id" {
  type=string
}

variable "security_group_ids" {
  type=list(string)
}

variable "tags" {
  type=map(string)
}
