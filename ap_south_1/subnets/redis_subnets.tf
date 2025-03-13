resource "aws_elasticache_subnet_group" "cache_subnet" {
  name       = "${var.project_name}-cache-subnet"
  subnet_ids = [for subnet in var.subnets.db_subnets : subnet.id]
}
