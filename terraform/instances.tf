resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "my-key-pair" # Replace with your desired key pair name
  public_key = file(var.public_key_path)
  tags = {
    project = var.project_name
  }
}

resource "aws_security_group" "react_jenkins_sg" {
  name        = "react-jenkins-sg"
  description = "Security group allowing SSH (22) and HTTP (80) ingress and all egress"
  vpc_id      = aws_vpc.main.id # Replace with your VPC ID

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
    Name    = "react-jenkins-sg"
    project = var.project_name
  }
}

resource "aws_instance" "staging_instance" {
  ami                         = var.aws_ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id

  # Security Group (optional, add an existing SG or use Terraform to create one)
  vpc_security_group_ids = [aws_security_group.react_jenkins_sg.id]

  # Key Pair for SSH Access
  key_name = aws_key_pair.ec2_key_pair.key_name

  # Add a basic block device (root volume)
  root_block_device {
    volume_size = 8 # 8GB root volume
    volume_type = "gp3"
  }

  # Add Tags
  tags = {
    Name     = "staging-server"
    project  = var.project_name
    env      = "dev"
    function = "webserver"
  }
}

resource "aws_instance" "production_instance" {
  ami                         = var.aws_ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id

  # Security Group (optional, add an existing SG or use Terraform to create one)
  vpc_security_group_ids = [aws_security_group.react_jenkins_sg.id]

  # Key Pair for SSH Access
  key_name = aws_key_pair.ec2_key_pair.key_name

  # Add a basic block device (root volume)
  root_block_device {
    volume_size = 8 # 8GB root volume
    volume_type = "gp3"
  }

  # Add Tags
  tags = {
    Name     = "production-server"
    project  = var.project_name
    env      = "prod"
    function = "webserver"
  }
}

resource "aws_instance" "jenkins_instance" {
  ami                         = var.aws_ami_id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id

  # Security Group (optional, add an existing SG or use Terraform to create one)
  vpc_security_group_ids = [aws_security_group.react_jenkins_sg.id]

  # Key Pair for SSH Access
  key_name = aws_key_pair.ec2_key_pair.key_name

  # Add a basic block device (root volume)
  root_block_device {
    volume_size = 20 # 8GB root volume
    volume_type = "gp3"
  }

  # Add Tags
  tags = {
    Name     = "jenkins-server"
    project  = var.project_name
    function = "jenkins"
  }
}