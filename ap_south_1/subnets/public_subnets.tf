resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region_code}a"
  cidr_block              = "150.0.10.0/24"
  map_public_ip_on_launch = true
  # depends_on              = [ module.igw ]

  tags = {
    Name                     = "${var.project_name}-pub-subnet-${var.region_code}a"
    nat                      = "true"
    type                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region_code}c"
  cidr_block              = "150.0.20.0/24"
  map_public_ip_on_launch = true
  # depends_on              = [ module.igw ]

  tags = {
    Name                     = "${var.project_name}-pub-subnet-${var.region_code}c"
    nat                      = "false"
    type                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}
