resource "authentik_policy_expression" "google-whitelist-user-email-policy" {
  name = "google-whitelist2"
  expression = <<EOT
# Ensure flow is only run during oauth logins via Google
if context["source"].provider_type != "google":
    return True

# Whitelisted users
accepted_users = ["james@integratn.io",
                  "boboysdadda@gmail.com",
                  "chamorreanreject@gmail.com",
                ]
  EOT
}

resource "authentik_policy_expression" "google-userame-mapping-validation-policy" {
  name = "google-username-mapping-validation"
  expression = <<EOT
email = request.context["prompt_data"]["email"]

def capitalize_first_letters(email):
    username = email.split("@")[0]
    words = re.split(r'[\.\-_]', username)  # Split by ., -, and _
    capitalized_words = [word.capitalize() for word in words]
    return "".join(capitalized_words)

# Set username to email without domain and capitalized
request.context["prompt_data"]["username"] = capitalize_first_letters(email)
return False
  EOT
}

resource "authentik_policy_expression" "google-username-received-validation-policy" {
  name = "google-username-received-validation"
  expression = <<EOT
return 'username' not in context.get('prompt_data', {})
  EOT
}

resource "authentik_stage_prompt_field" "google-auth-prompt-field" {
  name = "google-auth-prompt-field"
  field_key = "username"
  label = "username"
  type = "username"
}


resource "authentik_stage_prompt" "google-auth-enrollement-prompt" {
  name = "google-auth-enrollment-prompt"
  fields = [authentik_stage_prompt_field.google-auth-prompt-field.id]
  validation_policies = [
    authentik_policy_expression.google-userame-mapping-validation-policy.id,
    authentik_policy_expression.google-username-received-validation-policy.id
    ]
}

resource "authentik_stage_user_write" "google-enrollment-stage-user-write" {
  name = "google-enrollment-stage-user-write"
  create_users_as_inactive = false
  user_creation_mode = "create_when_required"
  create_users_group = authentik_group.all-users.id
}

resource "authentik_stage_user_login" "google-enrollment-stage-user-login" {
  name = "google-enrollment-stage-user-login"
  geoip_binding = "bind_continent_country_city"
  network_binding = "bind_asn_network_ip"
  session_duration = "hours=6"
  remember_me_offset = "minutes=30"
}

resource "authentik_flow" "google_source_enrollement_flow" {
  name = "google-source-enrollment-flow"
  title = "Welcome to Integratn.IO! Please Login with Google to continue."
  slug = "google-source-enrollment-flow"
  designation = "enrollment"
}

resource "authentik_policy_binding" "google-enrollment-pre-flow-policies" {
  target = authentik_flow.google_source_enrollement_flow.uuid
  policy = authentik_policy_expression.google-whitelist-user-email-policy.id
  order = 0
}

resource "authentik_flow_stage_binding" "google-enrollment-stage-binding" {
  target = authentik_flow.google_source_enrollement_flow.uuid
  stage = authentik_stage_prompt.google-auth-enrollement-prompt.id
  order = 0
}

resource "authentik_flow_stage_binding" "google-enrollment-stage-user-write-binding" {
  target = authentik_flow.google_source_enrollement_flow.uuid
  stage = authentik_stage_user_write.google-enrollment-stage-user-write.id
  order = 1
}

resource "authentik_flow_stage_binding" "google-enrollment-stage-user-login-binding" {
  target = authentik_flow.google_source_enrollement_flow.uuid
  stage = authentik_stage_user_login.google-enrollment-stage-user-login.id
  order = 2
}



