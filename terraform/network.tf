########### Collection of networking resources on region 1 #########

# VPC for region1
resource "aws_vpc" "vpc_region1" {
  provider             = aws.region1
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name    = "vpc_region1"
    project = var.project_name
    region  = var.region1
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_region1" {
  provider                = aws.region1
  vpc_id                  = aws_vpc.vpc_region1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_region1
  tags = {
    Name    = "public_subnet_region1"
    project = var.project_name
    region  = var.region1
  }
}

# Additional subnet in region1
resource "aws_subnet" "public_subnet_region1_az2" {
  provider                = aws.region1
  vpc_id                  = aws_vpc.vpc_region1.id
  cidr_block              = "10.0.2.0/24"  # Different CIDR block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone2_region1  # Different AZ
  
  tags = {
    Name    = "public_subnet_region1_az2"
    project = var.project_name
    region  = var.region1
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw_region1" {
  provider = aws.region1
  vpc_id   = aws_vpc.vpc_region1.id
  tags = {
    Name    = "igw_region1"
    project = var.project_name
    region  = var.region1
  }
}

# Route Table
resource "aws_route_table" "public_rt_region1" {
  provider = aws.region1
  vpc_id   = aws_vpc.vpc_region1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_region1.id
  }

  tags = {
    Name    = "public_rt_region1"
    project = var.project_name
    region  = var.region1
  }
}

# Route for Internet Access
# resource "aws_route" "default_route_region1" {
#   provider             = aws.region1
#   route_table_id         = aws_route_table.public_rt_region1.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw_region1.id
# }

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_association_region1" {
  provider       = aws.region1
  subnet_id      = aws_subnet.public_subnet_region1.id
  route_table_id = aws_route_table.public_rt_region1.id
}

resource "aws_route_table_association" "public_association_region1_az2" {
  provider       = aws.region1
  subnet_id      = aws_subnet.public_subnet_region1_az2.id
  route_table_id = aws_route_table.public_rt_region1.id
}


########## End of resources for region 1 ##########


########## Collection of networking resources on region 2 ######### 

# VPC for region2
resource "aws_vpc" "vpc_region2" {
  provider             = aws.region2
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "vpc_region2"
    project = var.project_name
    region  = var.region2
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_region2" {
  provider                = aws.region2
  vpc_id                  = aws_vpc.vpc_region2.id
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_region2

  tags = {
    Name    = "public_subnet_region2"
    project = var.project_name
    region  = var.region2
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw_region2" {
  provider = aws.region2
  vpc_id   = aws_vpc.vpc_region2.id

  tags = {
    Name    = "igw_region2"
    project = var.project_name
    region  = var.region2
  }
}

# Route Table
resource "aws_route_table" "public_rt_region2" {
  provider = aws.region2
  vpc_id   = aws_vpc.vpc_region2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_region2.id
  }

  tags = {
    Name    = "public_rt_region2"
    project = var.project_name
    region  = var.region2
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_association_region2" {
  provider       = aws.region2
  subnet_id      = aws_subnet.public_subnet_region2.id
  route_table_id = aws_route_table.public_rt_region2.id
}

########## End of resources for region 2 ##########

########## Collection of networking resources for VPC peering ######### 

# VPC Peering Connection
resource "aws_vpc_peering_connection" "peer" {
  provider    = aws.region1
  vpc_id      = aws_vpc.vpc_region1.id
  peer_vpc_id = aws_vpc.vpc_region2.id
  peer_region = var.region2
  auto_accept = false

  tags = {
    Name    = "vpc-peer-region1-region2"
    project = var.project_name
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.region2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
}

# Update route tables for VPC peering
resource "aws_route" "route_region1_to_region2" {
  provider                  = aws.region1
  route_table_id            = aws_route_table.public_rt_region1.id
  destination_cidr_block    = aws_vpc.vpc_region2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_region2_to_region1" {
  provider                  = aws.region2
  route_table_id            = aws_route_table.public_rt_region2.id
  destination_cidr_block    = aws_vpc.vpc_region1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


########## End of resources for VPC peering between region1 and region2 ##########

