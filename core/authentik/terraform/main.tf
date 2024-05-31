data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "random_pet" "authentik-provider-oauth2-name" {
  length = 2
  prefix = "authentik-provider-oauth2"
}

data "onepassword_vault" "homelab" {
  name = "homelab"
}

resource "onepassword_item" "authentik-provider-oauth2" {
  title = "authentik provider oauth2"
  vault = data.onepassword_vault.homelab.uuid
  category = "password"
  password_recipe {
    length = 32
    digits = true
    symbols = false
    letters = true
  }

  section {
    label = "authentik provider oauth2"
    field {
      label = "client_id"
      type = "STRING"
      value = random_pet.authentik-provider-oauth2-name.id
    }
  }
  
  # username = random_pet.authentik-provider-oauth2-name.id
}

resource "authentik_provider_oauth2" "backstage-dev" {
  name  = "Backstage Dev"
  client_id  = random_pet.authentik-provider-oauth2-name.id
  client_secret = onepassword_item.authentik-provider-oauth2.password
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "backstage-dev" {
  name = "Backstage Dev"
  slug = "backstage-dev"
  protocol_provider = authentik_provider_oauth2.backstage-dev.id
  meta_launch_url = "https://localhost:3000"

}