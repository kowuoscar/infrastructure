variable "hcloud_token" {
    description = "Hetzner Cloud API token"
    type = string
    sensitive = true
}

variable "location" {
  description = "Hetzner datacenter location (nbg1=Nuremberg, fsn1=Falkenstein, hel1=Helsinki)"
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Hetzner server type for cluster nodes"
  type        = string
  default     = "cx23"
}
