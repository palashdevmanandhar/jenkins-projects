output "ec2_public_ip_stage" {
  value       = aws_instance.staging_instance.public_ip
  description = "The public IP of the staging EC2 instance"
}

output "ec2_jenkins_control" {
  value       = aws_instance.jenkins_control.public_ip
  description = "The public IP of the jenkins EC2 instance"
}

output "ec2_jenkins_node" {
  value       = aws_instance.jenkins_node1.public_ip
  description = "The public IP of the jenkins EC2 instance"
}

# output "ec2_public_ip_prod_node1" {
#   value       = aws_instance.production_instance_node1.public_ip
#   description = "The public IP of the staging EC2 instance"
# }

# output "ec2_public_ip_prod_node2" {
#   value       = aws_instance.production_instance_node2.public_ip
#   description = "The public IP of the staging EC2 instance"
# }


output "alb_dns" {
  value       = aws_lb.alb_region1.dns_name
  description = "Check alb dns"
}


output "ecr_repository_url" {
  value       = aws_ecr_repository.react_image_repo.repository_url
  description = "Check alb dns"
}
