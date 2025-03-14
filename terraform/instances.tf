######### Start of instances for Region1 ########

resource "aws_key_pair" "key_pair_region1" {
  provider   = aws.region1
  key_name   = "key_pair_region1" # Replace with your desired key pair name
  public_key = file(var.public_key_path)

  tags = {
    project = var.project_name
    region  = var.region1
  }
}

resource "aws_security_group" "sg_region1" {
  provider    = aws.region1
  name        = "sg_region1"
  description = "Security group allowing SSH (22) and HTTP (80) ingress and all egress"
  vpc_id      = aws_vpc.vpc_region1.id # Replace with your VPC ID

  # Ingress Rules
  ingress {
    description = "Allow SSH from all"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from all"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rules
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "sg_region1"
    project = var.project_name
    region  = var.region1
  }
}

resource "aws_security_group" "prod_sg" {
  provider    = aws.region1
  name        = "prod-instance-security-group"
  description = "Security group for EC2 instances in target group"
  vpc_id      = aws_vpc.vpc_region1.id

  # Allow inbound traffic only from ALB
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow SSH access for management
  ingress {
    description = "Allow SSH from all"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to your IP range
  }

  # Egress Rules
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "prod-instance-security-group"
    project = var.project_name
    region  = var.region1
  }
}

resource "aws_instance" "staging_instance" {
  provider                    = aws.region1
  ami                         = var.aws_ami_id_region1
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_region1.id

  # Security Group (optional, add an existing SG or use Terraform to create one)
  vpc_security_group_ids = [aws_security_group.sg_region1.id]

  # Key Pair for SSH Access
  key_name = aws_key_pair.key_pair_region1.key_name

  # Add a basic block device (root volume)
  root_block_device {
    volume_size = 8 # 8GB root volume
    volume_type = "gp3"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_ecr_profile.name


  # Add Tags
  tags = {
    Name     = "staging-server"
    project  = var.project_name
    env      = "dev"
    function = "webserver"
    region   = var.region1
  }
}

# Create instances for prod deployment
# resource "aws_instance" "production_instance_node1" {
#   provider                    = aws.region1
#   ami                         = var.aws_ami_id_region1
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.public_subnet_region1.id

#   # Security Group (optional, add an existing SG or use Terraform to create one)
#   vpc_security_group_ids = [aws_security_group.prod_sg.id]

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
#   vpc_security_group_ids = [aws_security_group.prod_sg.id]

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

resource "aws_instance" "jenkins_control" {
  provider                    = aws.region1
  ami                         = var.aws_ami_id_region1
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_region1.id

  # Security Group (optional, add an existing SG or use Terraform to create one)
  vpc_security_group_ids = [aws_security_group.sg_region1.id]

  # Key Pair for SSH Access
  key_name = aws_key_pair.key_pair_region1.key_name

  # Add a basic block device (root volume)
  root_block_device {
    volume_size = 20 # 8GB root volume
    volume_type = "gp3"
  }

  # Add Tags
  tags = {
    Name     = "jenkins_control"
    project  = var.project_name
    function = "jenkins"
    region   = var.region1
    type     = "control"
  }
}


######### End of instances for Region1 ########

######### Start of instances for Region1 ########


resource "aws_key_pair" "key_pair_region2" {
  provider   = aws.region2
  key_name   = "key_pair_region2" # Replace with your desired key pair name
  public_key = file(var.public_key_path)

  tags = {
    project = var.project_name
    region  = var.region2
  }
}

resource "aws_security_group" "sg_region2" {
  provider    = aws.region2
  name        = "sg_region2"
  description = "Security group allowing SSH (22) and HTTP (80) ingress and all egress"
  vpc_id      = aws_vpc.vpc_region2.id
  depends_on  = [aws_vpc.vpc_region2]

  # Ingress Rules
  ingress {
    description = "Allow SSH from all"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from all"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rules
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "sg_region2"
    project = var.project_name
    region  = var.region2
  }
}


# Resource for jenkins worker node in a different region
# resource "aws_instance" "jenkins_node1" {
#   provider                    = aws.region2
#   ami                         = var.aws_ami_id_region2
#   instance_type               = "t2.medium"
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.public_subnet_region2.id

#   # Security Group (optional, add an existing SG or use Terraform to create one)
#   vpc_security_group_ids = [aws_security_group.sg_region2.id]

#   # Key Pair for SSH Access
#   key_name = aws_key_pair.key_pair_region2.key_name

#   # Add a basic block device (root volume)
#   root_block_device {
#     volume_size = 20 # 8GB root volume
#     volume_type = "gp3"
#   }

#   # Add Tags
#   tags = {
#     Name     = "jenkins_node1"
#     project  = var.project_name
#     function = "jenkins"
#     region   = var.region2
#     type     = "node"
#   }
# }


######### End of instances for Region2 ########