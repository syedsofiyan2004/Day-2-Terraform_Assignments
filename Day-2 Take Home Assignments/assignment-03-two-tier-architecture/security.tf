provider "aws" {
  region=var.aws_region
}

resource "aws_vpc" "main_vpc" {
  cidr_block="10.0.0.0/16"

  tags = {
    Name="day-two-sofiyan-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id=aws_vpc.main_vpc.id

  tags = {
    Name="day-two-sofiyan-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id=aws_vpc.main_vpc.id
  cidr_block="10.0.1.0/24"
  map_public_ip_on_launch=true

  tags = {
    Name = "day-two-sofiyan-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id=aws_vpc.main_vpc.id
  cidr_block="10.0.2.0/24"

  tags = {
    Name="day-two-sofiyan-private-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id=aws_vpc.main_vpc.id

  route {
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.igw.id
  }

  tags = {
    Name="day-two-sofiyan-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id=aws_subnet.public_subnet.id
  route_table_id=aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  domain="vpc"

  tags = {
    Name="day-two-sofiyan-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id=aws_eip.nat_eip.id
  subnet_id=aws_subnet.public_subnet.id

  tags = {
    Name="day-two-sofiyan-nat-gw"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id=aws_vpc.main_vpc.id

  route {
    cidr_block="0.0.0.0/0"
    nat_gateway_id=aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name="day-two-sofiyan-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id=aws_subnet.private_subnet.id
  route_table_id=aws_route_table.private_rt.id
}
