terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.70.0"
    }
  }

  backend "s3" {
    bucket = "klabs-state-bucket"
    key    = "cluster/terraform.tfstate"
    region = "fsn1"
    endpoints = {
      s3 = "https://fsn1.your-objectstorage.com"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "hcloud" {
  token = var.hcloud_token
}