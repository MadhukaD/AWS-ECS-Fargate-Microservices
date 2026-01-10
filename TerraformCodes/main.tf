# ────────────────────────────────
# VPC + Subnets + IGW + NAT
# ────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  name_prefix             = var.name_prefix
  vpc_cidr                = var.vpc_cidr
  aws_region              = var.aws_region

  public_subnet_01_cidr   = var.public_subnet_01_cidr
  public_subnet_02_cidr   = var.public_subnet_02_cidr
  private_subnet_01_cidr  = var.private_subnet_01_cidr
  private_subnet_02_cidr  = var.private_subnet_02_cidr

  map_public_ip_on_launch = var.map_public_ip_on_launch
}

# ────────────────────────────────
# Security Groups + Key Pair
# ────────────────────────────────
module "security" {
  source = "./modules/security"

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id

  public_subnet_01_id = module.vpc.public_subnet_01_id
  public_subnet_02_id = module.vpc.public_subnet_02_id
}

# ────────────────────────────────
# Application Load Balancer (ALB)
# ────────────────────────────────
module "alb" {
  source = "./modules/alb"

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id

  public_subnet_01_id = module.vpc.public_subnet_01_id
  public_subnet_02_id = module.vpc.public_subnet_02_id

  alb_sg_id = module.security.security_group2_id
}

# ────────────────────────────────
# CodeCommit Repositories & ECR Repositories
# ────────────────────────────────
module "codecommit_ecr" {
  source = "./modules/codecommit&ecr"

  name_prefix = var.name_prefix
}

# # ────────────────────────────────
# # CodeBuild projects and IAM
# # ────────────────────────────────
# module "codebuild" {
#   source = "./modules/codebuild"

#   user_ecr_repository_arn    = module.codecommit_ecr.user_ecr_repository_arn
#   product_ecr_repository_arn = module.codecommit_ecr.product_ecr_repository_arn
# }