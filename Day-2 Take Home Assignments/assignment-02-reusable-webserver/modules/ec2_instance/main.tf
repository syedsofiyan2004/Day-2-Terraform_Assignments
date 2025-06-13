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
