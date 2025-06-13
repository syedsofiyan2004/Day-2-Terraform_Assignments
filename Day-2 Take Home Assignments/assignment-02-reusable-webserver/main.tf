 provider "aws" {
  region=var.aws_region
}

resource "aws_vpc" "main_vpc" {
  cidr_block="10.0.0.0/16"

  tags={
    Name="day-two-sofiyan-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id=aws_vpc.main_vpc.id
  cidr_block="10.0.1.0/24"
  map_public_ip_on_launch=true

  tags={
    Name="day-two-sofiyan-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id=aws_vpc.main_vpc.id

  tags={
    Name="day-two-sofiyan-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id=aws_vpc.main_vpc.id

  route {
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.igw.id
  }

  tags={
    Name="day-two-sofiyan-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id=aws_subnet.public.id
  route_table_id=aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  vpc_id=aws_vpc.main_vpc.id

  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }

  ingress {
    from_port   =22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name="day-two-sofiyan-sg"
  }
}

module "my_web_server" {
  source = "./modules/ec2_instance"

  instance_type=var.instance_type
  ami_id=var.web_server_ami
  subnet_id=aws_subnet.public.id
  security_group_ids=[aws_security_group.web_sg.id]
  tags={
    Name="day-two-sofiyan-ec2"
  }
}
