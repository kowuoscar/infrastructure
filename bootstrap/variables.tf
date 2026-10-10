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