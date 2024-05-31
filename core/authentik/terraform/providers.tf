terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.4.2"
    }
    onepassword = {
      source = "1Password/onepassword"
      version = "2.0.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "authentik" {
  # Set these ENV VARS
  # export AUTHENTIK_URL=https://...
  # export AUTHENTIK_TOKEN=<secret_token>
  # export AUTHENTIK_INSECURE=false
}

provider "onepassword" {
  # Set these ENV VARS
  # export OP_CONNECT_HOST=https://...
  # export OP_CONNECT_TOKEN=<secret
}

provider "random" {
}