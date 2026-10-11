variable "access_key" {
  description = "Hetzner S3 Access Key"
  type = string
  sensitive = true
}

variable "secret_key" {
  description = "Hetzner S3 Secret Key"
  type = string
  sensitive = true
}


variable "hcloud-credentials-project" {
  description = "S3 credentials project in Hetzner"
  type = string
  sensitive = true
}

variable "s3-ro-access-key" {
  description = "S3 Read-only Access Key"
  type = string
  sensitive = true
}

variable "s3-rw-access-key" {
  description = "S3 Read-Write Access key"
  type = string
  sensitive = true
}