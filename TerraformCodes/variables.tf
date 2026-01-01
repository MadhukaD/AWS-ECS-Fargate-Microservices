variable "name_prefix" {
  description = "Name prefix used for tagging and resource names"
  type        = string
  default     = "fargate-microservices"
}

variable "aws_access_key" {
  description = "instance_type of VM"
  type        = string
  default     = "AKIAVCELOVQB76BSVD5E"
}

variable "aws_secret_key" {
  description = "instance_type of VM"
  type        = string
  default     = "K4WP7J97nPkDnkh+UZr4YwMpgYsW0c1u+kO5mLFn" 
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-1"
}

variable "availability_zones" {
  description = "AZs to use (order matters). Provide at least 2 AZs for HA split."
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.80.0.0/16"
}

variable "public_subnet_01_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.80.0.0/24"
}

variable "public_subnet_02_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.80.1.0/24"
}

variable "private_subnet_01_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
  default     = "10.80.2.0/24"
}

variable "private_subnet_02_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
  default     = "10.80.3.0/24"
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}