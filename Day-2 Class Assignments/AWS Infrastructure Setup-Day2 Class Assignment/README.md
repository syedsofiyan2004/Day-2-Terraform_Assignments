# Day-2 Terraform Class Assignment AWS Infrastructure

## Building Basic AWS Infrastructure using Terraform:

For this assignment, I built a basic AWS infrastructure setup using Terraform, making sure it was neat and easy to manage. The main idea was to launch a simple web server on an EC2 instance within a custom VPC environment, using best practices like variables and outputs.

Initially, I started by setting up Terraform files, defining variables like the AWS region, instance type, and VPC CIDR block in a dedicated variables.tf file.This helped avoid repetitive manual changes later.
This is my **variables.tf** file looks like:
```sh
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
```

I have also created an outputs.tf file to quickly grab the EC2 instance’s public IP after everything was running
This is how my **outputs.tf** file looks like:
```sh
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "instance_id" {
  value = aws_instance.web_server.id
}

output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}
```

Then, I moved onto the network side of things. I created a VPC to keep my AWS resources secure and isolated. Inside that VPC, I made a public subnet and attached an Internet Gateway so that resources like my EC2 instance could connect to the internet. To make sure the subnet knew how to reach the internet, I added a route table directing outbound traffic through the gateway.
this is how i made those resources implementing in terraform which is in the **main.tf** file:
```sh
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "day-two-syed_sofiyan-vpc"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "day-two-syed_sofiyan-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "day-two-syed_sofiyan-igw"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "day-two-syed_sofiyan-rt"
  }
}
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
```
Next, I created a security group to control traffic to my EC2 instance. I opened up HTTP (**port 80**) for the web server and SSH (**port 22**) access just in case I needed to log into the server directly.
This is also in the part of my **main.tf** code:
```sh
resource "aws_security_group" "web_sg" {
  name        = "day-two-syed_sofiyan-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["14.98.177.234/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "day-two-syed_sofiyan-sg"
  }
}
```
After setting up the network and security, I finally launched my EC2 instance using Amazon Linux 2. I included a simple startup script that automatically installed Apache and created a basic webpage saying **"Hello World from Syed Sofiyan!"**.
This implementation is also the part of my **main.tf** file:
```sh
resource "aws_instance" "web_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World from Syed Sofiyan - $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
  tags = {
    Name = "day-two-syed_sofiyan-ec2"
  }
}
```
Once everything was set up, I ran terraform init, waited a few moments
```sh
terraform init
```
![image](https://github.com/user-attachments/assets/1f1aedc6-989e-460b-8ef8-11c45f60b182)

Then to validate the syntax, to check if there is any error in any of the codes i used the following command:
```sh
terraform validate
```
![image](https://github.com/user-attachments/assets/244f5f1c-7c53-4604-ac71-6a16fe815192)

Then to check any changes are required is everything safe to create or anything is missing out I typed the following command:
```sh
terraform plan
```
![Screenshot 2025-06-14 170318](https://github.com/user-attachments/assets/ce7381f9-1883-4c1d-954f-3c8f813b82e8)
![Screenshot 2025-06-14 170331](https://github.com/user-attachments/assets/7732f420-8ee2-45d7-99c4-70d17e78eeba)
![Screenshot 2025-06-14 170346](https://github.com/user-attachments/assets/3c7894f0-ed96-4f6f-9f9b-482e27eebe77)

As we can see in the images the resources are ready to be created now we can proceed for terraform apply:
```sh
terraform apply
```
![Screenshot 2025-06-14 170634](https://github.com/user-attachments/assets/ef230563-2a39-46f5-bbee-2b8f7feed70c)
![Screenshot 2025-06-14 170643](https://github.com/user-attachments/assets/f4edd214-1d43-40a6-b0a5-0ea38fb40e3a)
![Screenshot 2025-06-14 170651](https://github.com/user-attachments/assets/710ff924-b01a-4a1d-80ac-2914e400d056)
![Screenshot 2025-06-14 170714](https://github.com/user-attachments/assets/f2959e3a-56d0-4175-a2f1-5dd75d6b128f)

As we can see we got the outputs as VPC's id Subnet's id instance's ID and finally, also got the IP Address of the Ec2 instance lets check whether its Working or not:
```sh
http://13.127.104.31
```
![image](https://github.com/user-attachments/assets/71d81213-cf72-49ec-b4ff-359448c2f2e5)

As we can see that its working lets check whether the reources are created or not in the AWS Console:
![image](https://github.com/user-attachments/assets/1ee07f70-876a-45e7-a8f3-6f677fcf5911)

as we can see the resource map the resources are created:
![Screenshot 2025-06-14 171211](https://github.com/user-attachments/assets/83aca2a5-535a-4041-8982-6c4fbcd17f82)
![Screenshot 2025-06-14 171227](https://github.com/user-attachments/assets/cde3f5d2-2c28-4fdc-8606-e18e476de97a)
![Screenshot 2025-06-14 171240](https://github.com/user-attachments/assets/88698bab-7e6f-4e81-93ef-2633ea51a583)
![Screenshot 2025-06-14 171253](https://github.com/user-attachments/assets/7c0a466a-6fe1-4c84-ba7c-99e98f171052)
![Screenshot 2025-06-14 171309](https://github.com/user-attachments/assets/dc8fa84b-6d5f-4fe5-8c05-db4b6feecf4a)
![Screenshot 2025-06-14 171328](https://github.com/user-attachments/assets/317f377a-173d-4b02-add4-afeb0ff49488)

The Resources are created now we have to do the Cleanup Job 
we can do that with just one command it is:
```sh
terraform destroy
```
![Screenshot 2025-06-14 171608](https://github.com/user-attachments/assets/ccf33fef-f556-48cc-9e06-bda3e971fe5c)
![Screenshot 2025-06-14 171625](https://github.com/user-attachments/assets/67c2d308-8d19-418a-b4c5-0469a8328537)

As you can see the resources are destroyed completely using only the terraform


### These are the Deliverables for this Assignment

# End of this Assignment
