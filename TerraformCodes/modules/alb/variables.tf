variable "name_prefix" {
  description = "Prefix for naming security resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to attach security group"
  type        = string
}

variable "public_subnet_01_id" {
  description = "Public subnet 1 ID"
  type        = string
}

variable "public_subnet_02_id" {
  description = "Public subnet 2 ID"
  type        = string
}

variable "alb_sg_id" {
  description = "ALB Security Group ID"
  type        = string
}