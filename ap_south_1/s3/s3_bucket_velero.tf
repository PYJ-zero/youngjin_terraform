resource "aws_s3_bucket" "velero_bucket" {
  bucket = "${var.project_name}-velero-s3"
  force_destroy = true
}
