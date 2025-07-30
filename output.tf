output "nagios_public_ip" {
  value = aws_instance.nagios_server.public_ip
}
