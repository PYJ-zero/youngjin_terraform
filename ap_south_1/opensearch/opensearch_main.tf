module "test_opensearch" {
  source  = "terraform-aws-modules/opensearch/aws"
  version = "~> 2.0"

  domain_name = "${var.project_name}-opensearch"

  cluster_config = {
    instance_type  = "t3.small.search"
    instance_count = 1
  }

  ebs_options = {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp3"
  }

  engine_version = "OpenSearch_2.11"

  node_to_node_encryption = false
  encrypt_at_rest         = false

  domain_endpoint_options = {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  access_policies = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/your-user-name"
        },
        Action = "es:*",
        Resource = "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/test-opensearch/*"
      }
    ]
  })

  tags = {
    Environment = "test"
    Project     = "youngjin"
  }
}

data "aws_caller_identity" "current" {}