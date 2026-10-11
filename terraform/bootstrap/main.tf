resource "minio_s3_bucket" "klabs-state-bucket" {
  bucket         = "klabs-state-bucket"
  acl            = "private"
  object_locking = false
}

resource "minio_s3_bucket_policy" "policy" {
  bucket = minio_s3_bucket.klabs-state-bucket.bucket
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "CiReadWrite",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam:::user/p${var.hcloud-credentials-project}:${var.s3-rw-access-key}"
        },
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource": [
          "arn:aws:s3:::klabs-state-bucket",
          "arn:aws:s3:::klabs-state-bucket/*"
        ]
      },
      {
        "Sid": "LocalReadOnly",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam:::user/p${var.hcloud-credentials-project}:${var.s3-ro-access-key}"
        },
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        "Resource": [
          "arn:aws:s3:::klabs-state-bucket",
          "arn:aws:s3:::klabs-state-bucket/*"
        ]
      }
    ]
  })
}

resource "minio_s3_bucket_versioning" "klabs-state-bucket" {
  bucket = minio_s3_bucket.klabs-state-bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}
