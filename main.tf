Terraform
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

# Public Subnet (one per Availability Zone)
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = format("Public-Subnet-%s", count.index + 1)
  }
}

# Security Group (allow SSH only from your IP)
resource "aws_security_group" "ssh" {
  name = "SSHSecurityGroup"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["<YOUR_IP_ADDRESS>/32"]  # Replace with your IP address
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "ec2" {
  count = 1

  ami           = "ami-0123456789abcdef0" # Replace with desired AMI ID
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id = aws_subnet.public[0].id

  # Use user data script (optional)
  user_data = var.user_data

  tags = merge(var.tags, {
    Name = "My-EC2-Instance"
  })
}

# Output details
output "public_ip" {
  value = aws_instance.ec2[0].public_ip
  description = "Public IP address of the EC2 instance"
}

output "instance_id" {
  value = aws_instance.ec2[0].id
  description = "ID of the EC2 instance"
}


====================================================================================


# Create EBS volume
resource "aws_ebs_volume" "my_volume" {
  availability_zone = var.availability_zones[0]  # Specify the availability zone where the instance is launched
  size              = 10  # Size of the EBS volume in GiB
  tags = {
    Name = "MyEBSVolume"
  }
}

# Attach EBS volume to EC2 instance
resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/xvdf"  # Device name to attach the volume to (replace with appropriate device name)
  volume_id   = aws_ebs_volume.my_volume.id
  instance_id = aws_instance.ec2.id
}
