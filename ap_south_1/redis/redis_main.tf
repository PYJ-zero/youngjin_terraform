module "this" {
  source    = "cloudposse/label/null"
  namespace = "prd"
  stage     = "youngjin"
  name      = "redis-cluster-01"
}

module "redis" {
  source = "cloudposse/elasticache-redis/aws"

  availability_zones         = ["${var.region_code}a", "${var.region_code}c"]
  vpc_id                     = var.vpc_id
  allowed_security_group_ids = [var.security_groups.redis_sg.id]
  subnets                    = [for subnet in var.db_subnet.private_pri_subnets : subnet.id]
  cluster_size               = "2"
  instance_type              = "cache.m6g.large"
  apply_immediately          = true
  automatic_failover_enabled = true
  engine_version             = "6.2"
  family                     = "redis6.x"

  context = module.this.context
}
