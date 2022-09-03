# Create an github-actions policy in the devops namespace
resource "vault_policy" "vault_actions" {
  namespace = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace = vault_namespace.devops.path
  name   = "vault-actions"
  policy = file("policies/devops-secrets.hcl")

}
