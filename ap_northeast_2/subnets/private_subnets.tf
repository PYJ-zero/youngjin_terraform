resource "aws_subnet" "private_pri_subnet_a" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.region_code}a"
  cidr_block        = "150.0.30.0/24"

  tags = {
      Name     = "${var.project_name}-subnet-service-ap2a"
      type     = "private"
  }
}

resource "aws_subnet" "private_pri_subnet_c" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.region_code}c"
  cidr_block        = "150.0.40.0/24"

  tags = {
      Name     = "${var.project_name}-subnet-service-ap2c"
      type     = "private"
  }
}