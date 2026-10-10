terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.44.0"
    }
  }

  backend "s3" {
    
  }
}

provider "minio" {
  minio_server   = "fsn1.your-objectstorage.com"
  minio_user     = var.access_key
  minio_password = var.secret_key
  minio_region   = "fsn1"
  minio_ssl      = true
}

resource "minio_s3_bucket" "klabs-state-bucket" {
  bucket         = "klabs-state-bucket"
  acl            = "private"
  object_locking = false
}

resource "minio_s3_bucket_versioning" "klabs-state-bucket" {
  bucket = "klabs-state-bucket"

  versioning_configuration {
    status = "Enabled"
  }
}
