#------------------------------------------------------------------------------
# The best practice is to use remote state file and encrypt it since your
# state files may contains sensitive data (secrets).
#------------------------------------------------------------------------------

#terraform cloud backend:
terraform {
  cloud {
    organization = "lomar"
    workspaces {
      name = "vault-management"
    }
  }
  required_providers {
    vault = "~> 3.8.0"
  }
}

provider "vault" {
  address = data.terraform_remote_state.vault_infra.outputs.public_endpoint
  token   = data.terraform_remote_state.vault_infra.outputs.admin_token
  #namespace = data.terraform_remote_state.vault_infra.outputs.namespace
}


data "terraform_remote_state" "vault_infra" {
  backend = "remote"
  config = {
    organization = "lomar"
    workspaces = {
      name = "vault-config"
    }
  }
}

#create Namespace 
#resource "vault_namespace" "devops" {
#  path = "devops"
#}