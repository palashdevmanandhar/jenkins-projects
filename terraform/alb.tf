############ Begining of ALB resources for Region1 ##########

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  provider    = aws.region1
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.vpc_region1.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name    = "alb-security-group"
    region  = var.region1
    project = var.project_name
  }
}

# Application Load Balancer in Region 1
resource "aws_lb" "alb_region1" {
  provider           = aws.region1
  name               = "alb-region1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_region1.id, aws_subnet.public_subnet_region1_az2.id]

  tags = {
    project = var.project_name
    env     = "prod"
    region  = var.region1
  }
}

# ALB Target Group
resource "aws_lb_target_group" "tg_region1" {
  provider = aws.region1
  name     = "tg-region1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_region1.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    timeout             = 5
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    unhealthy_threshold = 2
  }

  tags = {
    project = var.project_name
    env     = "prod"
    region  = var.region1
  }
}


# Use if you have to register independent instances to alb target group
# Register production instances with target group
# resource "aws_lb_target_group_attachment" "tg_attachment_region1_prod_node1" {
#   provider         = aws.region1
#   target_group_arn = aws_lb_target_group.tg_region1.arn
#   target_id        = aws_instance.production_instance_node1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "tg_attachment_region1_prod_node2" {
#   provider         = aws.region1
#   target_group_arn = aws_lb_target_group.tg_region1.arn
#   target_id        = aws_instance.production_instance_node2.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "tg_attachment_region2" {
#   provider         = aws.region1
#   target_group_arn = aws_lb_target_group.tg_region1.arn
#   target_id        = aws_instance.production_instance_region2.id
#   port             = 80
# }

# ALB Listener
resource "aws_lb_listener" "front_end" {
  provider          = aws.region1
  load_balancer_arn = aws_lb.alb_region1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_region1.arn
  }
}

resource "aws_launch_template" "prod_server_lt" {
  provider = aws.region1
  name     = "prod-server-launch-template"

  image_id      = var.aws_ami_id_region1
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.prod_sg.id]
  }

  key_name = aws_key_pair.key_pair_region1.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr_profile.name
  }


  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Install docker
              dnf install -y docker

              # Start and enable docker service
              systemctl start docker
              systemctl enable docker

              # Create docker group if it doesn't exist
              groupadd -f docker

              # Add ec2-user to docker group
              usermod -aG docker ec2-user

              # Get ECR authentication token and login
              aws ecr get-login-password --region ${var.region1} | docker login --username AWS --password-stdin ${aws_ecr_repository.react_image_repo.repository_url}

              # Restart docker to ensure group changes take effect
              systemctl restart docker
              EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name     = "prod-asg-web-server"
      project  = var.project_name
      env      = "prod"
      function = "webserver"
      region   = var.region1
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_server_asg" {
  provider = aws.region1
  name     = "web-server-asg"

  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  target_group_arns = [aws_lb_target_group.tg_region1.arn]
  vpc_zone_identifier = [
    aws_subnet.public_subnet_region1.id,
    aws_subnet.public_subnet_region1_az2.id
  ]

  launch_template {
    id      = aws_launch_template.prod_server_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "prod-asg-web-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "prod"
    propagate_at_launch = true
  }
}

# Optional: Add scaling policies
resource "aws_autoscaling_policy" "prod_scale_up" {
  provider               = aws.region1
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
}

resource "aws_autoscaling_policy" "prod_scale_down" {
  provider               = aws.region1
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
}

############ End of ALB resources for Region1 ##########