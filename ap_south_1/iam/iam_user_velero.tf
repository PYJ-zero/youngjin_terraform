resource "aws_iam_user" "velero" {
  name = "${var.project_name}-velero"
}

resource "aws_iam_policy" "velero_policy" {
  name        = "${var.project_name}_VeleroPolicy"
  description = "Policy for Velero to backup and restore EKS resources."
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:PutObjectTagging",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "${var.s3_list.velero_bucket.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "${var.s3_list.velero_bucket.arn}"
            ]
        }
    ]
})
}

resource "aws_iam_user_policy_attachment" "velero_policy_attach" {
  user       = aws_iam_user.velero.name
  policy_arn = aws_iam_policy.velero_policy.arn
}

resource "aws_iam_access_key" "velero" {
  user = aws_iam_user.velero.name
}