output "ec2_public_ip_stage" {
  value       = aws_instance.staging_instance.public_ip
  description = "The public IP of the staging EC2 instance"
}

output "ec2_jenkins" {
  value       = aws_instance.jenkins_instance.public_ip
  description = "The public IP of the jenkins EC2 instance"
}

output "ec2_public_ip_prod_region1" {
  value       = aws_instance.production_instance_region1.public_ip
  description = "The public IP of the staging EC2 instance"
}

output "ec2_public_ip_prod_region2" {
  value       = aws_instance.production_instance_region2.public_ip
  description = "The public IP of the staging EC2 instance"
}

