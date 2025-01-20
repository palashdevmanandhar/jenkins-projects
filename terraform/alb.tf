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
    Name = "alb-security-group"
    region = region1
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
  subnets            = [aws_subnet.public_subnet_region1.id]

  tags = {
    project  = var.project_name
    env      = "prod"
    region = var.region1
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
    project  = var.project_name
    env      = "prod"
    region = var.region1
  } 
}

# Register production instances with target group
resource "aws_lb_target_group_attachment" "tg_attachment_region1" {
  provider         = aws.region1
  target_group_arn = aws_lb_target_group.tg_region1.arn
  target_id        = aws_instance.production_instance_region1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_region2" {
  provider         = aws.region1
  target_group_arn = aws_lb_target_group.tg_region1.arn
  target_id        = aws_instance.production_instance_region2.id
  port             = 80
}

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

############ End of ALB resources for Region1 ##########