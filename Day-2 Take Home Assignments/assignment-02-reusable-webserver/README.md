# Day-2 Terraform Take Home Assignment
## Making a reusable Web-Server EC2 Instance

In this assignment, I learned how to refactor my Terraform EC2 web server into a reusable module. The main idea was to avoid repeating resource definitions and keep my Terraform code clean and easy to manage.

First, I created a structured directory in my repo named assignment-02-reusable-webserver. Inside it, I added another folder called modules, and within that, an ec2_instance directory. This organized structure kept my reusable module clearly separated from my main Terraform code.
![Screenshot 2025-06-14 195004](https://github.com/user-attachments/assets/42adcc46-174e-456c-a314-3b5af220fda0)

Inside the **modules/ec2_instance** directory, I made three essential files:
**main.tf:** Moved my existing EC2 instance resource into this file.
```sh
 resource "aws_instance" "web_server" {
  ami=var.ami_id
  instance_type=var.instance_type
  subnet_id=var.subnet_id
  vpc_security_group_ids=var.security_group_ids
  associate_public_ip_address=true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Module - Syed Sofiyan</h1>" > /var/www/html/index.html
    EOF

  tags=var.tags
}
```
**variables.tf:** Converted all the hardcoded values like instance type, AMI ID, subnet ID, security groups, and tags into variables. This way, I could easily reuse the module with different configurations.
```sh
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
```
**outputs.tf:** Created outputs for the instance’s id and public_ip, allowing me to reference them from the main configuration later.
```sh
 output "id" {
  value=aws_instance.web_server.id
}

output "public_ip" {
  value=aws_instance.web_server.public_ip
}
```

Then, back in the root **assignment-02-reusable-webserver** folder, I updated the main Terraform files:
**main.tf:** Set up networking resources like the VPC, subnet, internet gateway, route tables, and security groups. Instead of directly creating the EC2 instance here, I now called my newly created module, passing in required variables.
```sh
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
```
**variables.tf:** Defined variables for AWS region, EC2 instance type, and AMI ID, making the root configuration easy to manage.
```sh
 variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "web_server_ami" {
  description = "AMI ID for EC2 Instance"
}
```
**outputs.tf:** Added an output to retrieve the public IP of my web server directly from the module output (**module.my_web_server.public_ip**).
```sh
 output "web_server_public_ip" {
  description = "Public IP of the EC2 instance created by the module."
  value       = module.my_web_server.public_ip
}
```

Next, I configured the AWS provider and backend storage in my backend.tf file. The backend ensures Terraform state management is handled securely in an S3 bucket.
I have created S3 Bucket Manually for S3 Remote Backend:
![image](https://github.com/user-attachments/assets/7257c844-d9c1-477a-ae99-74e25b077ad3)
![image](https://github.com/user-attachments/assets/d5bf8c1d-4960-43ea-b989-c70c8048d378)
![image](https://github.com/user-attachments/assets/b402ea55-becb-4f33-9091-2770ba0848ee)

And then added this code in the **backend.tf** file:
```sh
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }

  backend "s3" {
    bucket = "sofiyan-terraform-state-20250612"
    key    = "assignment-02/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

After finishing the setup, I ran terraform init to initialize the module.
```sh
terraform init
```
![Screenshot 2025-06-13 123238](https://github.com/user-attachments/assets/dea4b894-fecd-40c9-9a15-837b8b6350eb)

again to check syntax errors I valiated my Terraform codes:
```sh
terraform validate
```
![Screenshot 2025-06-13 123251](https://github.com/user-attachments/assets/99ab5b41-41ff-419e-a371-049119a96d5a)

Then followed by terraform plan to check if there is any change required in creating these resources:
```sh
terraform plan
```
![Screenshot 2025-06-13 123542](https://github.com/user-attachments/assets/40a18811-a812-4df4-99d1-70b90b7e3ca7)
![Screenshot 2025-06-13 123554](https://github.com/user-attachments/assets/34ceb0bd-9cc6-4cb3-889d-1b231872f119)
![Screenshot 2025-06-13 123604](https://github.com/user-attachments/assets/c4819c2f-d0e8-4105-8adf-701ea1f7cb27)
![Screenshot 2025-06-13 123647](https://github.com/user-attachments/assets/700c8644-aef5-4a24-82cd-cb289659424f)

then followed by terraform apply for creating the resources:
```sh
terraform apply
```
![Screenshot 2025-06-13 124152](https://github.com/user-attachments/assets/8785f23e-d73c-4c8d-87e3-d738d2a74645)
![Screenshot 2025-06-13 125549](https://github.com/user-attachments/assets/026aef2b-e13a-4276-a39d-f9bbcece7cf7)

As we can see we got an output as an Public IP address of the EC2 instance let's check if its working or not:
```sh
http://43.204.141.115
```
![Screenshot 2025-06-13 125601](https://github.com/user-attachments/assets/d10d51eb-a6fa-4931-89da-d0434a5426d8)

As we can see we got the Message from Module Ec2 instances which proves that our Assignment is a successful

## This is final Deliverable of this Assignment

Now to check our **terraform.tfstate** file we have to do to our S3 Bucket which we have created in the console:
![Screenshot 2025-06-13 125627](https://github.com/user-attachments/assets/e16b7e0f-0bef-462e-816b-be839ad77643)
![Screenshot 2025-06-13 125634](https://github.com/user-attachments/assets/216618b3-892b-4e67-92b8-ff7e8268e53f)
![Screenshot 2025-06-13 125642](https://github.com/user-attachments/assets/3c8ae8c4-c094-47d8-ac03-90b0e1696321)

As we can see that our state file is safe in our S3 Bucket this proves that our S3 Remote Backend is Acheived, now let's proceed to our Cleanup Job

The cleanup Job can be done by only one command:
```
terraform destroy
```
![Screenshot 2025-06-14 201954](https://github.com/user-attachments/assets/a0287b33-9800-42fb-afda-effbb1660972)
![Screenshot 2025-06-14 202020](https://github.com/user-attachments/assets/e2954e13-bec1-4358-8b10-11f6cf6f595f)

And also we have to manually delete our S3 Backend Bucket too:
![image](https://github.com/user-attachments/assets/f5617899-addf-4925-a3ce-a7aec0a0e29f)
![image](https://github.com/user-attachments/assets/7a5e7189-48ab-49a7-818f-cb7c0287d8d3)
![image](https://github.com/user-attachments/assets/f565a2f6-8fd5-41b7-b669-61ecd3883288)

As all the resources are destroyed our cleanUp job is done

# End of this Assignment
















