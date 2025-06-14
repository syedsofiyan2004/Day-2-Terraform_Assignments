# Day-2 take Home Assignments
## Building a static website

In this assignment, I deployed a basic static website directly from an Amazon S3 bucket using Terraform. This was a straightforward exercise that helped me practice creating resources, using variables, and outputs in Terraform. Below, I've explained briefly how I completed this assignment in an easy to follow manner.

First, I created a dedicated directory named **assignment-01-s3-static-website**. Inside this folder, I added a simple HTML file called **index.html**. This file contained a basic webpage stating clearly, “**This website was deployed using Terraform By Syed Sofiyan**!”.
![image](https://github.com/user-attachments/assets/c01839fa-8a6f-4716-8ccb-c646ca18b322)

The index.html contents are:
```sh
 <!DOCTYPE html>
<html>
<head>
  <title>My First Terraform Website</title>
</head>
<body>
  <h1>This website was deployed using Terraform!</h1>
  <p>Assignment 1 is a success from Syed Sofiyan.</p>
</body>
</html>
```

To keep my configuration clean and flexible, I created a **variables.tf** file where I defined:
The AWS region (ap-south-1).
A unique bucket name for my S3 bucket.
```sh
 variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "bucket_name" {
  type    = string
  default = "sofiyan-static-website-20250612"
}
```
Next, I configured the AWS provider and backend storage in my **backend.tf** file. The backend ensures Terraform state management is handled securely in an S3 bucket.
 I have created S3 Bucket Manually for S3 Remote Backend:
![Screenshot 2025-06-13 094413](https://github.com/user-attachments/assets/ee39304c-738e-4e4e-8834-98a90a64daae)
![Screenshot 2025-06-13 094433](https://github.com/user-attachments/assets/1af8931b-0fec-4829-b0b2-a1d10db6d8a6)
![Screenshot 2025-06-13 094702](https://github.com/user-attachments/assets/79ea1f4f-e6b0-4512-b41b-41750e592c90)

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
    bucket="sofiyan-terraform-state-20250612"
    key="assignment-01/terraform.tfstate"
    region="ap-south-1"
  }
}
```
In **main.tf**, I then defined several Terraform resources to host my website properly:

**S3 Bucket:** Created a new bucket with a globally unique name.

**Public Access Settings:** Explicitly allowed public access to my bucket by adjusting the S3 bucket public access block settings.

**Website Configuration:** Configured the bucket to serve index.html as the default page.

**Bucket Policy:** Set up a public-read policy allowing anyone to view the website content.

**Uploading Content:** Uploaded my local index.html file directly into the bucket.
```sh
provider "aws" {
  region=var.aws_region
}

resource "aws_s3_bucket" "static_website" {
  bucket=var.bucket_name

  tags = {
    Name="S3 Static Website"
    Owner="Syed Sofiyan"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket=aws_s3_bucket.static_website.id
  block_public_acls=false
  block_public_policy=false
  ignore_public_acls=false
  restrict_public_buckets=false
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket=aws_s3_bucket.static_website.id

  index_document {
    suffix="index.html"
  }
}

data "aws_iam_policy_document" "public_read" {
  statement {
    actions=["s3:GetObject"]
    resources=["${aws_s3_bucket.static_website.arn}/*"]
    principals {
      type= "AWS"
      identifiers=["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket=aws_s3_bucket.static_website.id
  policy=data.aws_iam_policy_document.public_read.json
}

resource "aws_s3_object" "index_html" {
  bucket=aws_s3_bucket.static_website.bucket
  key="index.html"
  source="${path.module}/index.html"
  content_type = "text/html"
}
```

To neatly display my deployed website's URL after provisioning, I also created an **outputs.tf** file. Here, I defined an output variable called website_endpoint, which easily provided the website’s URL once Terraform finished deploying.
```sh
 output "website_endpoint" {
  value=aws_s3_bucket_website_configuration.website_config.website_endpoint
}
```
After creating and editing these files i have runned the terraform init command:
```sh
terraform init
```
![Screenshot 2025-06-13 095432](https://github.com/user-attachments/assets/cc8ae10a-037c-4aac-a07f-caa9d2c6700a)

then Terraform validate to check any Syntax errors:
```sh
terraform validate
```
![Screenshot 2025-06-13 095909](https://github.com/user-attachments/assets/eba49f99-f063-4138-a082-3f2fc5b815c3)

then terraform plan to see if we need any changes in the creating of the resources or not:
```sh
terraform plan
```
![Screenshot 2025-06-13 095943](https://github.com/user-attachments/assets/14ebd4ed-781e-4469-a465-d0443688fd42)
![Screenshot 2025-06-13 095952](https://github.com/user-attachments/assets/729f45d8-e6d8-4bcb-a2b2-cb81a7cf35c5)
![Screenshot 2025-06-13 100019](https://github.com/user-attachments/assets/b461d69b-844f-4632-a211-e46c2891a6cd)
![Screenshot 2025-06-13 100046](https://github.com/user-attachments/assets/54c4af5c-fe43-4509-b1cf-c823e3e4a6ee)

As everything is clear we can move on to the terraform apply to crate the resources:
```sh
terraform apply
```
![Screenshot 2025-06-13 102346](https://github.com/user-attachments/assets/6cfc474d-4bba-4fe0-970c-6cf59df75126)
![Screenshot 2025-06-13 102400](https://github.com/user-attachments/assets/119560b3-77c2-47e3-8720-f98af11de770)
![Screenshot 2025-06-13 102507](https://github.com/user-attachments/assets/992043f9-6a8e-46bf-ae4f-76a072f8968b)

As we can see in the image the resources got created and the output we got is the URL:
```sh
http://sofiyan-static-website-20250612.s3-website.ap-south-1.amazonaws.com
```
If we direct to this link we can see if the static website is working or not:
![Screenshot 2025-06-13 102552](https://github.com/user-attachments/assets/833a4515-2850-4b8e-a15c-59fd29091f79)

As the message is being displayed in the static Website the Assignment is a Success.
### This is the final Deliverable for this Assignment


![Screenshot 2025-06-13 102652](https://github.com/user-attachments/assets/514bc1c5-b5ac-4fdc-9bed-0847a7db6d7a)
As we can see there are two buckets, one bucket is **sofiyan-static-website-20250612** which stores our static website as we can see in the above image, and the other bucket is **sofiyan-terraform-state-20250612** which stores our **terraform.tfstate** file.

Lets see our terrafor.tfstate file is present or not:
![Screenshot 2025-06-13 102917](https://github.com/user-attachments/assets/05bae927-03df-4ba8-9178-62c2918872f8)
![Screenshot 2025-06-13 102924](https://github.com/user-attachments/assets/d560722f-61b3-4e85-b25a-2a170aeeb7af)

As we can see in the image that the terraform.tfsate file is safe in the S3 bucket which proves that we have done the S3 remote Backend.

As our assignment is completed we have to do the cleanup Job, we can do this by doing terraform destroy:
```sh
terraform destroy
```
![Screenshot 2025-06-13 103134](https://github.com/user-attachments/assets/3dd8abd7-aeb7-4c1d-9231-a5e9e2823d58)
![Screenshot 2025-06-13 103145](https://github.com/user-attachments/assets/8b20e8f0-5b7c-460f-ab59-b7b5ebba0fbf)
![Screenshot 2025-06-13 103218](https://github.com/user-attachments/assets/7eb0de34-0f56-4923-9996-059f26ca71bf)
![Screenshot 2025-06-13 103251](https://github.com/user-attachments/assets/2d0ada3c-cd1e-4408-9247-6530bb62c9f5)

As we can see that the resources are now have been destroyed and we need to delete that S3 bucket manually which we have created manually for S3 remote backend:
![Screenshot 2025-06-13 104324](https://github.com/user-attachments/assets/fb1381ae-3175-4172-bd0e-baadfe821f42)

## The Cleanup Job has been done

# End of this Assignment














