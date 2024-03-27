variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones for subnets"
}

variable "public_sg_ingress" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr_blocks = list(string)
  }))
  description = "Ingress rules for public security group"
}

variable "private_sg_ingress" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr_blocks = list(string)
  }))
  description = "Ingress rules for private security group"
}

variable "ssh_key_name" {
  type = string
  description = "Name of existing SSH key pair"
}
