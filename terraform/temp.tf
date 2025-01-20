# VPC for region2
resource "aws_vpc" "vpc_region2" {
  provider             = aws.region2
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "main-vpc"
    project = var.project_name
    region = var.region2
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_region2" {
  provider             = aws.region2
  vpc_id                  = aws_vpc.vpc_region2.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_region_1
  tags = {
    Name    = "public_subnet_region2"
    project = var.project_name
    region = var.region2
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw_region2" {
  provider             = aws.region2
  vpc_id = aws_vpc.vpc_region2.id
  tags = {
    Name    = "igw_region2"
    project = var.project_name
    region = var.region2
  }
}

# Route Table
resource "aws_route_table" "public_rt_region2" {
  provider             = aws.region2
  vpc_id = aws_vpc.vpc_region2.id
  tags = {
    Name    = "public_rt_region2"
    project = var.project_name
    region = var.region2
  }
}

# Route for Internet Access
resource "aws_route" "default_route_region2" {
  provider             = aws.region2
  route_table_id         = aws_route_table.public_rt_region2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_region2.id
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_association_region2" {
  provider             = aws.region2
  subnet_id      = aws_subnet.public_subnet_region2.id
  route_table_id = aws_route_table.public_rt_region2.id
}