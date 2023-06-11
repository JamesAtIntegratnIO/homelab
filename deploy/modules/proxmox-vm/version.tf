terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~>2.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>3.3"
    }
  }
  required_version = ">=1.4"
}
provider "proxmox" {
  pm_api_url          = "https://10.0.1.101:8006/api2/json"
  pm_api_token_id     = var.API_TOKEN_ID
  pm_api_token_secret = var.API_TOKEN_SECRET
  pm_tls_insecure     = true
  pm_debug            = true
}