# Day-2  Terraform Take Home Assignment
## Building two-tier Architecture using Terraform

In this assignment, I am going to build two-tier AWS architecture consisting of a publicly accessible web server and a secure, private database. The goal was to practice setting up secure network segments, creating proper security group rules, and managing Terraform configurations neatly.

First, I created a new directory called assignment-03-two-tier-architecture. 
![image](https://github.com/user-attachments/assets/464355f7-eafe-4525-bf88-df4eca8cdd44)

To keep things organized, I split my Terraform files into clear sections:
**network.tf:** for defining the VPC, subnets (public and private), internet gateway, NAT gateway, and route tables.
I began by creating a custom VPC with two subnets:

**Public Subnet:** for the web server, accessible from the internet via an Internet Gateway.

**Private Subnet:** isolated from public internet access, hosting my RDS database.

For secure updates and patches in the private subnet, I also configured a NAT Gateway within the public subnet. This way, my database could access the internet when needed, without exposing itself directly.
```sh
resource "aws_security_group" "web_sg" {
  vpc_id=aws_vpc.main_vpc.id

  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }

  ingress {
    from_port=22
    to_port=22
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }

  egress {
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"]
  }

  tags = {
    Name="day-two-sofiyan-web-sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id=aws_vpc.main_vpc.id

  ingress {
    from_port=3306
    to_port=3306
    protocol="tcp"
    security_groups=[aws_security_group.web_sg.id]
  }

  egress {
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"]
  }

  tags = {
    Name="day-two-sofiyan-db-sg"
  }
}
```
**security.tf:** to clearly define security groups for my web server and database server.
I set up two security groups carefully to ensure proper security:
Web Server Security Group **(day-two-sofiyan-web-sg)**:

Allowed HTTP **(port 80)** and SSH **(port 22)** inbound from anywhere.
Database Security Group **(day-two-sofiyan-db-sg):**

No direct public inbound rules.

Only allowed inbound traffic on MySQL's port (**3306**) from the web server’s security group. This restricted access ensures the database remains secure from external threats.

```sh
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
```

**main.tf:** containing the EC2 web server and the RDS database instances.
Web Server (EC2):
Launched a small EC2 instance (t2.micro) in the public subnet.
Attached it to the web_sg security group for accessibility.

Database (RDS Instance):
Provisioned a lightweight RDS MySQL instance (db.t2.micro) securely inside the private subnet.
Assigned it the db_sg security group to maintain secure access control.

Stored the database credentials securely using Terraform's sensitive variable functionality to avoid exposure in logs or outputs.
```sh
resource "aws_instance" "web_server" {
  ami=var.ami_id
  instance_type=var.instance_type
  subnet_id=aws_subnet.public_subnet.id
  vpc_security_group_ids=[aws_security_group.web_sg.id]
  associate_public_ip_address=true
  key_name=var.key_name

  user_data = <<-EOF
   #!/bin/bash
    yum update -y
    yum install -y httpd mysql
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Two-Tier Web Server By Syed Sofiyan</h1>" > /var/www/html/index.html
    EOF

  tags = {
    Name="day-two-sofiyan-web-server"
  }
}

resource "aws_db_instance" "database" {
  allocated_storage=20
  storage_type="gp2"
  engine="mysql"
  engine_version="8.0.36"
  instance_class="db.t2.micro"
  db_name="sofiyan_database"
  username=var.db_username
  password=var.db_password
  skip_final_snapshot=true
  publicly_accessible=false
  db_subnet_group_name=aws_db_subnet_group.db_subnets.id
  vpc_security_group_ids=[aws_security_group.db_sg.id]

  tags = {
    Name="day-two-sofiyan-rds"
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name="day-two-sofiyan-subnet-group"
  subnet_ids=[aws_subnet.private_subnet.id]

  tags = {
    Name="DB Subnet Group"
  }
}
```

**variables.tf and outputs.tf:** to manage configurable values and easy access to essential outputs like IP addresses and endpoints.
To make it easy to verify the setup later, I created outputs clearly showing:
Public IP address of my EC2 web server.
RDS database endpoint address, needed to connect from the web server.

```sh
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
```
```sh
output "web_server_public_ip" {
  value=aws_instance.web_server.public_ip
}

output "database_endpoint" {
  value=aws_db_instance.database.endpoint
}
```

After implementing this setup we need to run terraform init:
```sh
terrafirm init
```
![Screenshot 2025-06-13 200427](https://github.com/user-attachments/assets/02d286ae-8d46-4b96-94a3-0daf723749dd)

then run terraform plan:
```sh
terraform plan
```
![Screenshot 2025-06-13 200601](https://github.com/user-attachments/assets/5539a248-791c-47e0-ad75-481235b0f9be)
![Screenshot 2025-06-13 200624](https://github.com/user-attachments/assets/1f996240-36ca-4c82-87f3-4c6f1dc468f5)

then run terraform apply:
```sh
terraform apply
```
![Screenshot 2025-06-13 200855](https://github.com/user-attachments/assets/e56fd467-76ad-4448-8447-2140169e2c0b)
![Screenshot 2025-06-13 201610](https://github.com/user-attachments/assets/e1ed40b4-e889-414d-919a-b03fdc03de4c)

As we can see in the image we need to create a Subnet group for running an RDS instance but we dont have any access the terraform destroy gave an error cause we dont have access as an IAM role so we can't proceed further

## This is the unexpected Deliverable of this assignment becuase of Access Denied in IAM roles

# End of this Assignmennt






