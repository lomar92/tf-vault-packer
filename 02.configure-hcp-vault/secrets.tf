#AWS Secrets Engine

#AWS_CONFIG
resource "vault_aws_secret_backend" "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = "eu-central-1"
  namespace  = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace  = vault_namespace.devops.path

}

#AWS_ROLE_SETUP
resource "vault_aws_secret_backend_role" "role" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "github-actions-aws"
  credential_type = "iam_user"
  namespace       = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace       = vault_namespace.devops.path

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOT
}

#configure k/v secrets engine for HCP Secrets
resource "vault_mount" "kvv2" {
  path      = "cloud-secrets"
  type      = "kv"
  namespace = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace   = vault_namespace.devops.path
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "secret" {
  mount     = vault_mount.kvv2.path
  namespace = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace           = vault_namespace.devops.path
  name                = "hcp-secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      HCP_CLIENT_ID     = var.HCP_CLIENT_ID,
      HCP_CLIENT_SECRET = var.HCP_CLIENT_SECRET
    }
  )
}