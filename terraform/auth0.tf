provider "auth0" {
  domain = "https://dev-example.us.auth0.com"
  debug  = false
}

# Create a new Auth0 application for the JHipster app
resource "auth0_client" "java_ms_client" {
  name                = "JavaMicroservices"
  description         = "Java Microservices Client Created Through Terraform"
  app_type            = "regular_web"
  callbacks           = ["http://localhost:8080/login/oauth2/code/oidc", "http://aws-elb-id.region.elb.amazonaws.com:8080/login/oauth2/code/oidc"]
  allowed_logout_urls = ["http://localhost:8080", "http://aws-elb-id.region.elb.amazonaws.com:8080"]
  oidc_conformant     = true

  jwt_configuration {
    alg = "RS256"
  }
}

# Configuring client_secret_post as an authentication method.
resource "auth0_client_credentials" "java_ms_client_creds" {
  client_id = auth0_client.java_ms_client.id

  authentication_method = "client_secret_post"
}

# Create roles for JHipster app
resource "auth0_role" "admin" {
  name        = "ROLE_ADMIN"
  description = "Administrator"
}

resource "auth0_role" "user" {
  name        = "ROLE_USER"
  description = "User"
}

# Create an action to customize the authentication flow to add the roles and the username to the access token claims expected by JHipster applications.
resource "auth0_action" "jhipster_action" {
  name    = "jhipster_roles_claim"
  runtime = "node18"
  deploy  = true
  code    = <<-EOT
  /**
   * Handler that will be called during the execution of a PostLogin flow.
   *
   * @param {Event} event - Details about the user and the context in which they are logging in.
   * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
   */
   exports.onExecutePostLogin = async (event, api) => {
     const namespace = 'https://www.jhipster.tech';
     if (event.authorization) {
         api.idToken.setCustomClaim('preferred_username', event.user.email);
         api.idToken.setCustomClaim(namespace + '/roles', event.authorization.roles);
         api.accessToken.setCustomClaim(namespace + '/roles', event.authorization.roles);
     }
   };
  EOT

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

# attach the action to the login flow
resource "auth0_trigger_actions" "login_flow" {
  trigger = "post-login"

  actions {
    id           = auth0_action.jhipster_action.id
    display_name = auth0_action.jhipster_action.name
  }
}

# Create a test user. You can create more users here if needed
resource "auth0_user" "test_user" {
  connection_name = "Username-Password-Authentication"
  name            = "Jane Doe"
  email           = "jhipster@test.com"
  email_verified  = true
  password        = "passpass$12$12" # Don't set passwords like this in production! Use env variables instead.
  lifecycle {
    ignore_changes = [roles]
  }
}

resource "auth0_user_roles" "test_user_roles" {
  user_id = auth0_user.test_user.id
  roles   = [auth0_role.admin.id, auth0_role.user.id]
}

output "auth0_webapp_client_id" {
  description = "Auth0 JavaMicroservices Client ID"
  value       = auth0_client.java_ms_client.client_id
}

output "auth0_webapp_client_secret" {
  description = "Auth0 JavaMicroservices Client Secret"
  value       = auth0_client_credentials.java_ms_client_creds.client_secret
  sensitive   = true
}
