output "ec2_public_ip_stage" {
  value = aws_instance.staging_instance.public_ip
  description = "The public IP of the staging EC2 instance"
}

output "ec2_public_ip_prod" {
  value = aws_instance.production_instance.public_ip
  description = "The public IP of the staging EC2 instance"
}