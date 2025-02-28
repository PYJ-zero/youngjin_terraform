//  인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
      Name     = "${var.project_name}-igw"
  }
}
