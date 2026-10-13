variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "source_ip" {
  description = "Local IP address"
  type        = string
  sensitive   = true
}