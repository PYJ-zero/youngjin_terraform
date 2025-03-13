module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "${var.project_name}-aurora-mysql"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  instance_class = "db.r7g.large"
  instances = {
    01 = {}
    02 = {}
  }
  autoscaling_enabled      = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 5
  skip_final_snapshot      = true
  database_name            = "yougnjindb"
  master_username          = "yougnjin"
  master_password          = "test123!@#"

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet.db_subnet.name
  security_group_rules = {
    ex1_ingress = {
      cidr_blocks = ["150.0.40.0/24"]
    }
    ex2_ingress = {
      cidr_blocks = ["150.0.30.0/24"]
    }
  }

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10


  tags = {
    Environment = "prd"
    Terraform   = "true"
  }
}
