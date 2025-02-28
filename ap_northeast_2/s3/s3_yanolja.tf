resource "aws_s3_bucket" "youngjin-s3" {
  bucket = "${var.project_name}-s3"
  acl    = "private"
}