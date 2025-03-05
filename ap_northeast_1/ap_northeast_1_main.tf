### 기초가 되는 AWS 리소스 제외하고 Terraform에서 제공하는 module 활용###
#########################################################################

resource "aws_vpc" "vpc" {
    cidr_block = "150.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
  tags = {
      Name     = "${var.project_name}-EKS-CICD-TEST-VPC"
  }
}

module "subnets" {
  source         = "./subnets"
  project_name   = var.project_name
  vpc_id         = aws_vpc.vpc.id
  region_code    = var.region_code
  subnets        = module.subnets.subnet_list
}

module "security_group" {
  source         = "./security_groups"
  project_name   = var.project_name
  vpc_id         = aws_vpc.vpc.id
}

module "igw" {
  source         = "./igw"
  depends_on     = [module.subnets]
  vpc_id         = aws_vpc.vpc.id
  project_name   = var.project_name
}

module "eip" {
  source         = "./eip"
  project_name   = var.project_name
  depends_on     = [module.subnets]
  vpc_id         = aws_vpc.vpc.id
  nat_subnets    = module.subnets.subnet_list.private_nat_subnets
}

module "nat" {
  source         = "./nat"
  project_name   = var.project_name
  depends_on     = [module.eip]
  nat_subnets    = module.subnets.subnet_list.private_nat_subnets
  nat_eip        = module.eip.nat_eip
  vpc_id         = aws_vpc.vpc.id
}

module "route_table" {
  source         = "./route_table"
  project_name   = var.project_name
  depends_on     = [module.subnets]
  vpc_id         = aws_vpc.vpc.id
  igw_id         = module.igw.igw_id
  nat            = module.nat.nat
  subnets        = module.subnets.subnet_list
}

# module "s3"{
#   source = "./s3"
#   project_name  = var.project_name
#   s3_list       = module.s3.s3_list
# }

module "eks" {
  source         = "./eks"
  project_name   = var.project_name
  subnets        = module.subnets.subnet_list
  vpc_id         = aws_vpc.vpc.id
}

module "rds" {
  source         = "./rds"
  project_name   = var.project_name
  subnets        = module.subnets.subnet_list
  vpc_id         = aws_vpc.vpc.id
  db_subnet      = module.subnets.db_subnet
}

module "efs" {
  source         = "./efs"
  project_name   = var.project_name
  subnets        = module.subnets.subnet_list
  region_code    = var.region_code
  vpc_id         = aws_vpc.vpc.id
  security_groups = module.security_group.security_groups
} 

# module "redis" {
#   source         = "./redis"
#   project_name   = var.project_name
#   db_subnet      = module.subnets.subnet_list
#   vpc_id         = aws_vpc.vpc.id
#   region_code    = var.region_code
#   security_groups   = module.security_group.security_groups
# }

module "endpoint" {
  source         = "./endpoint"
  project_name   = var.project_name
  vpc_id         = aws_vpc.vpc.id
  route_table    = module.route_table.private_rtb
}

module "ec2" {
  source         = "./ec2"
  project_name   = var.project_name
  subnets        = module.subnets.subnet_list
  region_code    = var.region_code
  vpc_id         = aws_vpc.vpc.id
  security_groups = module.security_group.security_groups
  iam_instance_profile = module.iam.iam_role.ssm_instance_profile
  depends_on     = [module.subnets, module.iam]
}

module "iam" {
  source        = "./iam"
  project_name  = var.project_name
}