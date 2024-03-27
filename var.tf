Terraform
variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones for subnets"
}

variable "instance_type" {
  type = string
  description = "EC2 instance type (e.g., t2.micro)"
}

variable "ssh_key_name" {
  type = string
  description = "Name of existing SSH key pair"
}

variable "user_data" {
  type = string
  description = "User data script for the EC2 instance (optional)"
}

variable "tags" {
  type = map(string)
  description = "Tags for the EC2 instance"
}
