 output "web_server_public_ip" {
  description = "Public IP of the EC2 instance created by the module."
  value       = module.my_web_server.public_ip
}
