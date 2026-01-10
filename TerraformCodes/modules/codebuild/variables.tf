# variable "name_prefix" {
#   description = "Prefix for naming security resources"
#   type        = string
# }

# variable "vpc_id" {
#   description = "VPC ID to attach security group"
#   type        = string
# }

# variable "aws_region" {
#   type = string
# }

variable "user_ecr_repository_arn" {
    description = "ARN of the user service ECR repository"
    type        = string
}

variable "product_ecr_repository_arn" {
    description = "ARN of the product service ECR repository"
    type        = string
}