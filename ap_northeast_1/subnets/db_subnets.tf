resource "aws_subnet" "db_subnet_a" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region_code}a"
  cidr_block              = "150.0.50.0/24"
  map_public_ip_on_launch = true
  //depends_on              = [ module.igw ]

  tags = {
      Name     = "${var.project_name}-subnet-db-${var.region_code}a"
      nat      = "true"
      type     = "private"
  }
}

resource "aws_subnet" "db_subnet_c" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region_code}c"
  cidr_block              = "150.0.60.0/24"
  map_public_ip_on_launch = true
  //depends_on              = [ module.igw ]

  tags = {
      Name     = "${var.project_name}-subnet-db-${var.region_code}c"
      nat      = "false"
      type     = "private"
  }
}

resource "aws_db_subnet_group" "db_subnet"{
  name        = "${var.project_name}-db-subnet"
  subnet_ids  = [for subnet in var.subnets.db_subnets : subnet.id]
}