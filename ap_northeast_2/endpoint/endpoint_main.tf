module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = var.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      endpoints       = "gateway"
      route_table_ids = ["${var.route_table.id}"]
      tags            = { Name = "prd-youngjin-s3-endpoint" }
    },
  }
}