locals {
  oidc_provider = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  custom_ami_id = "ami-08bf55c35587713e8"
}

# EKS Cluster 생성
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.project_name}-eks-cluster-01"
  vpc_id          = var.vpc_id
  subnet_ids      = [for subnet in var.subnets.eks_subnets : subnet.id]
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_iam_role = false
  iam_role_arn    = var.iam_roles.eks_cluster_role.arn

  # 자동으로 cluster creator(현재 Terraform을 실행하는 주체)를 admin으로 등록하지 않도록 하려면 false로 설정
  enable_cluster_creator_admin_permissions = true

  # Bastion에서 EKS API 서버(443)에 접근할 수 있도록 추가 규칙 추가
  cluster_security_group_additional_rules = {
    bastion_access = {
      description              = "Allow Bastion SG access to EKS API server"
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      source_security_group_id = var.security_groups.bastion_sg.id
    }
  }

  eks_managed_node_groups = {
    "${var.project_name}-nodegroup-1" = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      # ami_type = "BOTTLEROCKET_x86_64"
      ami_type = "AL2_x86_64"
      # ami_id                 = local.custom_ami_id
      instance_types = ["t3a.large"]

      create_worker_iam_role = false
      worker_iam_role_arn    = var.iam_roles.eks_node_role.arn
      name                   = "${var.project_name}-ng-1"
      create_launch_template = true
      launch_template_name   = "${var.project_name}-ng-1-lt"

      subnet_ids = [for subnet in var.subnets.private_pri_subnets : subnet.id]
      # Amazon Linux 2 node groups do not require a specific settings block.
      # Any custom configuration (e.g. user data modifications) should be handled via a launch template if needed.
      min_size     = 3
      max_size     = 3
      desired_size = 3
    }
  }

  access_entries = {
    # One access entry with a policy associated
    ssm_role_access = {
      principal_arn = var.iam_roles.ssm_role.arn

      policy_associations = {
        eks_admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        cluster_admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Project = "${var.project_name}-eks-cluster"
  }
}
resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.36.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [module.eks]
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = "v2.0.8-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [module.eks]
}
resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  addon_version               = "v1.11.3-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [module.eks]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.29.7-eksbuild.5"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [module.eks]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.18.5-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [module.eks]
  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })
}

resource "aws_iam_role" "alb_controller_role" {
  name = "${var.project_name}-alb-controller-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : module.eks.oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_provider}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller",
            "${local.oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

#############################
#Role에 Policy Attach
#############################

resource "aws_iam_role_policy_attachment" "alb_controller_role_attach" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${var.project_name}_ALBControllerPolicy"
  description = "Policy for AWS ALB Controller to manage ELB resources."
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "ec2:GetSecurityGroupsForVpc",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTrustStores",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeCapacityReservation"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSecurityGroup"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "CreateSecurityGroup"
          },
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ],
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyListenerAttributes",
          "elasticloadbalancing:ModifyCapacityReservation"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "elasticloadbalancing:CreateAction" : [
              "CreateTargetGroup",
              "CreateLoadBalancer"
            ]
          },
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        "Resource" : "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule"
        ],
        "Resource" : "*"
      }
    ]
  })
}