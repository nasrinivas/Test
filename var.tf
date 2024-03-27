# Define variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for subnets in each availability zone"
  type        = list(string)
}

variable "acl_rules" {
  description = "ACL rules provided by the user"
  type        = list(object({
    rule_number   = number
    action        = string
    cidr_block    = string
    protocol      = number
    from_port     = number
    to_port       = number
  }))
}

variable "security_group_rules" {
  description = "Security group rules provided by the user"
  type        = list(object({
    type        = string
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
  }))
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create subnets in each availability zone
resource "aws_subnet" "my_subnets" {
  count             = length(var.subnet_cidr_blocks)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = "us-west-2a" # Replace with your desired AZ
}

# Create ACL rules
resource "aws_network_acl" "my_acl" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.acl_rules[0].from_port
    to_port     = var.acl_rules[0].to_port
    protocol    = var.acl_rules[0].protocol
    rule_action = var.acl_rules[0].action
    cidr_block  = var.acl_rules[0].cidr_block
  }

  egress {
    from_port   = var.acl_rules[1].from_port
    to_port     = var.acl_rules[1].to_port
    protocol    = var.acl_rules[1].protocol
    rule_action = var.acl_rules[1].action
    cidr_block  = var.acl_rules[1].cidr_block
  }
}

# Create security group
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "My Security Group"

  ingress {
    from_port   = var.security_group_rules[0].from_port
    to_port     = var.security_group_rules[0].to_port
    protocol    = var.security_group_rules[0].protocol
    cidr_blocks = var.security_group_rules[0].cidr_blocks
  }

  egress {
    from_port   = var.security_group_rules[1].from_port
    to_port     = var.security_group_rules[1].to_port
    protocol    = var.security_group_rules[1].protocol
    cidr_blocks = var.security_group_rules[1].cidr_blocks
  }

  vpc_id = aws_vpc.my_vpc.id
}

# Create EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-12345678" # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnets[0].id # Use the first subnet created

  security_groups = [aws_security_group.my_security_group.name]

  tags = {
    Name = "MyEC2Instance"
  }
}
