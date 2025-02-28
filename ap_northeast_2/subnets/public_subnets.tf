resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region_code}a"
  cidr_block              = "150.0.10.0/24"
  map_public_ip_on_launch = true
  # depends_on              = [ module.igw ]

  tags = {
      Name     = "${var.project_name}-subnet-public-ap2a"
      nat      = "true"
      type     = "public"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region_code}c"
  cidr_block              = "150.0.20.0/24"
  map_public_ip_on_launch = true
  # depends_on              = [ module.igw ]

  tags = {
      Name     = "${var.project_name}-subnet-public-ap2c"
      nat      = "false"
      type     = "public"
  }
}