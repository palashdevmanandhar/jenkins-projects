# terraform {
#   backend "s3" {
#     bucket         = "tf-state-react-jenkins"
#     key            = "terraform/state/terraform.tfstate" # Path to state file
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock" # Optional, for state locking
#     encrypt        = true                   # Encrypt state file at rest using AWS KMS
#   }
# }

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.region1
#   alias  = "region1"
# }

# provider "aws" {
#   region = var.region2
#   alias  = "region2"
# }


# ############ Begining of ALB resources for Region1 ##########

# # Security Group for ALB
# resource "aws_security_group" "alb_sg" {
#   provider    = aws.region1
#   name        = "alb-security-group"
#   description = "Security group for ALB"
#   vpc_id      = aws_vpc.vpc_region1.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name    = "alb-security-group"
#     region  = var.region1
#     project = var.project_name
#   }
# }

# # Application Load Balancer in Region 1
# resource "aws_lb" "alb_region1" {
#   provider           = aws.region1
#   name               = "alb-region1"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = [aws_subnet.public_subnet_region1.id, aws_subnet.public_subnet_region1_az2.id]

#   tags = {
#     project = var.project_name
#     env     = "prod"
#     region  = var.region1
#   }
# }

# # ALB Target Group
# resource "aws_lb_target_group" "tg_region1" {
#   provider = aws.region1
#   name     = "tg-region1"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc_region1.id

#   health_check {
#     enabled             = true
#     healthy_threshold   = 2
#     interval            = 30
#     timeout             = 5
#     path                = "/"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     matcher             = "200"
#     unhealthy_threshold = 2
#   }

#   tags = {
#     project = var.project_name
#     env     = "prod"
#     region  = var.region1
#   }
# }

# # Register production instances with target group
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


# # ALB Listener
# resource "aws_lb_listener" "front_end" {
#   provider          = aws.region1
#   load_balancer_arn = aws_lb.alb_region1.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg_region1.arn
#   }
# }

# ############ End of ALB resources for Region1 ##########

# resource "aws_key_pair" "key_pair_region1" {
#   provider   = aws.region1
#   key_name   = "key_pair_region1" # Replace with your desired key pair name
#   public_key = file(var.public_key_path)

#   tags = {
#     project = var.project_name
#     region  = var.region1
#   }
# }

# resource "aws_security_group" "sg_region1" {
#   provider    = aws.region1
#   name        = "sg_region1"
#   description = "Security group allowing SSH (22) and HTTP (80) ingress and all egress"
#   vpc_id      = aws_vpc.vpc_region1.id # Replace with your VPC ID

#   # Ingress Rules
#   ingress {
#     description = "Allow SSH from all"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Allow HTTP from all"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Allow HTTP from all"
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Egress Rules
#   egress {
#     description = "Allow all egress"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # "-1" allows all protocols
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name    = "sg_region1"
#     project = var.project_name
#     region  = var.region1
#   }
# }


# resource "aws_instance" "production_instance_node1" {
#   provider                    = aws.region1
#   ami                         = var.aws_ami_id_region1
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.public_subnet_region1.id

#   # Security Group (optional, add an existing SG or use Terraform to create one)
#   vpc_security_group_ids = [aws_security_group.sg_region1.id]

#   # Key Pair for SSH Access
#   key_name = aws_key_pair.key_pair_region1.key_name

#   # Add a basic block device (root volume)
#   root_block_device {
#     volume_size = 8 # 8GB root volume
#     volume_type = "gp3"
#   }

#   # Add Tags
#   tags = {
#     Name     = "production_instance_node1"
#     project  = var.project_name
#     env      = "prod"
#     function = "webserver"
#     region   = var.region1
#   }
# }

# resource "aws_instance" "production_instance_node2" {
#   provider                    = aws.region1
#   ami                         = var.aws_ami_id_region1
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.public_subnet_region1_az2.id

#   # Security Group (optional, add an existing SG or use Terraform to create one)
#   vpc_security_group_ids = [aws_security_group.sg_region1.id]

#   # Key Pair for SSH Access
#   key_name = aws_key_pair.key_pair_region1.key_name

#   # Add a basic block device (root volume)
#   root_block_device {
#     volume_size = 8 # 8GB root volume
#     volume_type = "gp3"
#   }

#   # Add Tags
#   tags = {
#     Name     = "production_instance_node2"
#     project  = var.project_name
#     env      = "prod"
#     function = "webserver"
#     region   = var.region1
#   }
# }