output "s3_list" {
  value = {
    # youngjin_s3 = aws_s3_bucket.youngjin_s3
    velero_bucket = aws_s3_bucket.velero_bucket
  }
}
