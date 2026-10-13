variable "api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Clouflare DNS Zone ID"
  type        = string
  default     = "16d7e881f9c7a6331df1366ebb46f2c5"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "kowulabs.com"
}