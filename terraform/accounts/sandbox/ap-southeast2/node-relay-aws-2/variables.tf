variable "aws_region" {
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
  type        = string
}

variable "aws_instance_type" {
  description = "The type of instance to start."
  type        = string
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in."
  type        = string
}

variable "release" {
  description = "NixOS release version."
  type        = string
}

variable "cidr_blocks" {
  description = "List of CIDR blocks."
  type        = list(string)
}

