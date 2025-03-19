resource "aws_subnet" "private_pri_subnet_a" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.region_code}a"
  cidr_block        = "150.0.30.0/24"

  tags = {
    Name                                          = "${var.project_name}-pri-subnet-${var.region_code}a"
    type                                          = "private"
    "kubernetes.io/role/internal-elb"             = "1"
    # "kubernetes.io/cluster/${var.eks_output.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_pri_subnet_c" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.region_code}c"
  cidr_block        = "150.0.40.0/24"

  tags = {
    Name                                          = "${var.project_name}-pri-subnet-${var.region_code}c"
    type                                          = "private"
    "kubernetes.io/role/internal-elb"             = "1"
    # "kubernetes.io/cluster/${var.eks_output.cluster_name}" = "shared"
  }
}
