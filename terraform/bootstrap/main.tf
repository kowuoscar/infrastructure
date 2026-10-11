resource "minio_s3_bucket" "klabs-state-bucket" {
  bucket         = "klabs-state-bucket"
  acl            = "private"
  object_locking = false
}

resource "minio_s3_bucket_versioning" "klabs-state-bucket" {
  bucket = minio_s3_bucket.klabs-state-bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}
