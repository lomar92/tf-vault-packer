#Enable OIDC / JWT for GitHub Actions Workflow

resource "vault_jwt_auth_backend" "github_actions" {
  description        = "This is GitHub Actions JWT"
  path               = "jwt"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
  default_role       = "github-actions"
  namespace          = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace          = vault_namespace.devops.path
}

resource "vault_jwt_auth_backend_role" "github_actions" {
  backend        = vault_jwt_auth_backend.github_actions.path
  role_name      = "github-actions"
  token_policies = ["hcp-root"]
  #  token_policies = [vault_policy.vault_actions.name]

  bound_claims_type = "glob"
  bound_claims = {
    sub : "repo:hashicorp-dach/tf-vault-packer:ref:refs/*"
  }

  bound_audiences = ["https://github.com/hashicorp-dach"]

  user_claim = "workflow"
  role_type  = "jwt"
  token_ttl  = "1800"
  namespace  = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace  = vault_namespace.devops.path
}
