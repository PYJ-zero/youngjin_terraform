module "efs" {
  source = "terraform-aws-modules/efs/aws"

  name           = "${var.project_name}-efs-01"
  encrypted      = true

  performance_mode                = "generalPurpose"
  throughput_mode                 = "bursting"

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  attach_policy                      = true
  bypass_policy_lockout_safety_check = false

  mount_targets = {
    "${var.region_code}a" = {
      subnet_id = var.subnets.private_pri_a_subnets.id
    }
    "${var.region_code}c" = {
      subnet_id = var.subnets.private_pri_c_subnets.id
    }
  }
  security_group_description = "Youngjin EFS SG"
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    vpc = {
      description = "EFS Inbound SG Rule"
      cidr_blocks = ["150.0.30.0/24", "150.0.40.0/24"]
    }
  }

  access_points = {
    root_example = {
      root_directory = {
        path = "/example"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  enable_backup_policy = true

  tags = {
    Terraform   = "true"
  }
}