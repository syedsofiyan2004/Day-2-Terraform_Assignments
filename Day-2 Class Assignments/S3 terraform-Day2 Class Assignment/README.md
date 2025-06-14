# Day-2 Class Assignment Terraform

## Building S3 Buckets and Remote Backend
In this assignment, I learned how to provision my first AWS resource using Terraform. The goal was straightforward: create an S3 bucket, manage its lifecycle, and securely handle Terraform state remotely. Here’s a brief overview of how I approached it.

Inside the **main.tf** file, I configured the AWS provider, specifying the AWS region (ap-south-1). Terraform uses these details to interact correctly with AWS. I also set the provider version to ensure compatibility.
```sh
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
```

Next, I defined an S3 bucket resource in the same file. I picked a unique bucket name since AWS requires it to be globally unique.
```sh
resource "aws_s3_bucket" "sofiyan_s3_bucket" {
  bucket = "minfy-training-sofiyan-s3-20250612"
  force_destroy = true
  tags = {
    Name = "My First Terraform Bucket"
  }
}
```
We can also use the tags for our own reference to make it more meaningful, but i have not used it here as it is just for our Assignment we can also add the tags such as Environments like "Production or Development" and also managedBy tag to write who is managing it and also the owner and more we can do more with these tags.

Now we have to run Terraform init:
```sh
terraform init
```
![Screenshot 2025-06-14 011958](https://github.com/user-attachments/assets/86803648-2cd0-4198-a9f2-4f43e21c3a05)

Now i will run Terraform validate to check the syntaxes:
```sh
terraform validate
```
![Screenshot 2025-06-14 012013](https://github.com/user-attachments/assets/7f7bd193-8bc1-4d38-a91f-c9d1a35e91e4)

Now i will run terraform plan to check the whether the changes are required for changes or not:
```sh
terraform plan
```
![Screenshot 2025-06-14 012050](https://github.com/user-attachments/assets/d0b6e978-4863-4ffc-9f23-0ddb53b4287d)
![Screenshot 2025-06-14 012103](https://github.com/user-attachments/assets/5555dddd-cdff-4b9b-b835-b9d1325a3825)

as we can see there is nothing to change so we can proceed with terraform apply:
```sh
terraform apply
```
![Screenshot 2025-06-14 012403](https://github.com/user-attachments/assets/17d7f980-f580-473f-b288-38a3b4406490)
![Screenshot 2025-06-14 012432](https://github.com/user-attachments/assets/70fa382a-343e-41dc-9278-445663064807)

As the resources are created lets check if the bucket is created in the AWS Console:

![Screenshot 2025-06-12 134508](https://github.com/user-attachments/assets/a4a36378-fdfa-4b61-b31a-b0aeff52d7dd)
As we can see in the image that the bucket has been created 

### I explored how Terraform manages resources using its state file (terraform.tfstate). This file links Terraform code with actual AWS resources. Initially, this state file was local, but that’s not practical for team projects because it’s vulnerable to loss or conflicts.
# AWS S3 Remote Backend
To overcome these limitations, I switched to a remote backend using AWS S3 for storage and DynamoDB for locking.

As You can see in the below image we dont have IAM Role Access to create a Dynamo DB table for state Locking so we have to proceed without using Dynamo DB table.
![image](https://github.com/user-attachments/assets/f9237141-b481-4b00-a6f9-966bb6919f22)

Now we have created the bucket in our earlier assignment, we will use that same bucket for S3 Backend we just need to add an extra **backend.tf** in our directory.
i have just added a small code for backend configuration:
```sh
terraform {
  backend "s3" {
    bucket = "minfy-training-sofiyan-s3-20250612"
    key    = "global/s3/terraform.tfstate"
    region = "ap-south-1"
  }
}
```
This code if running it will create a **terraform.tfstate** file in the S3 bucket which we have created earlier with name **minfy-training-sofiyan-s3-20250612** and in that bucket a directory will be created **global/s3/terraform.tfstate** and the terraform state file will be stored in it.

Now run the terraform init again:
![Screenshot 2025-06-14 012743](https://github.com/user-attachments/assets/b1dca197-f259-42db-8bdd-80c317e49a2e)

Here we can see that the Backend Configuration is added as the when we did terraform init which changed the configuration state.
![Screenshot 2025-06-14 012812](https://github.com/user-attachments/assets/cf625b47-bf3b-4a15-8031-e6e53820067c)
![Screenshot 2025-06-14 013013](https://github.com/user-attachments/assets/817b978b-e830-4d87-a690-31a9b7b7e28f)

After terraform plan and terraform apply the terraform state file will be created in that S3 bucket which we created in the Earlier Assignment:
![Screenshot 2025-06-12 134508](https://github.com/user-attachments/assets/48cf3924-7a54-40cd-9269-d2f459132656)
![Screenshot 2025-06-14 012854](https://github.com/user-attachments/assets/5dfad037-00cc-4fd9-88df-d9f2bfded479)
![Screenshot 2025-06-14 012900](https://github.com/user-attachments/assets/b2fdea26-dff4-49d9-9e7c-d37cb99fcd3d)
![Screenshot 2025-06-14 012910](https://github.com/user-attachments/assets/d886e400-0b2b-41b1-9c68-92884ae18e58)
![Screenshot 2025-06-14 012928](https://github.com/user-attachments/assets/165b2e03-618e-4c78-859c-2c2897da6d8c)

This shows that we have did an S3 Remote Backend.

## This is the final deliverable for this Assignment

Now lets do the cleanup use terraform destroy
![Screenshot 2025-06-14 014855](https://github.com/user-attachments/assets/dafb2242-b017-4a57-aa6b-8901ccd71e5b)
![Screenshot 2025-06-14 014911](https://github.com/user-attachments/assets/86801498-a09a-4b93-9ae9-ba67ee81777c)
![Screenshot 2025-06-14 014945](https://github.com/user-attachments/assets/f3bb39e9-2a7b-484e-baaa-c6d4901e970d)
As we can see that the S3 Bucket has been destroyed.

# End of Assignment




















