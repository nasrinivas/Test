# Configure AWS Provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "My-VPC"
  }
}

# Subnets (one per Availability Zone)
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = format("Public-Subnet-%s", count.index + 1)
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(var.availability_zones) + 1)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = format("Private-Subnet-%s", count.index + 1)
  }
}

# Internet Gateway (for public subnet access)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table (public subnet routes internet traffic)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Route Table Association (public subnet uses public route table)
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public[0].id
  route_table_id = aws_route_table.public.id
}

# Network ACL (default deny-all for private subnet)
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

   egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_block = "0.0.0.0/0"
  }
}

# Network ACL Association (private subnet uses private ACL)
resource "aws_subnet_network_acl_association" "private" {
  subnet_id = aws_subnet.private[0].id
  network_acl_id = aws_network_acl.private.id
}

# Security Groups (public allows SSH, private denies all)
resource "aws_security_group" "public" {
  name = "PublicSecurityGroup"
  vpc_id = aws_vpc.main.id

  ingress {
    for_each = var.public_sg_ingress
    from_port = each.value.from_port
    to_port   = each.value.to_port
    protocol  = each.value.protocol
    cid
