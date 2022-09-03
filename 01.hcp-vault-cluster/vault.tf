terraform {
  cloud {
    organization = "lomar"

    workspaces {
      name = "vault-config"
    }
  }
}

resource "hcp_hvn" "hcp_vault_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
}

resource "hcp_vault_cluster" "hcp_vault" {
  hvn_id     = hcp_hvn.hcp_vault_hvn.hvn_id
  cluster_id = var.cluster_id
  tier       = var.tier
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "vault_token" {
  cluster_id = hcp_vault_cluster.hcp_vault.cluster_id
} 
 
output "public_endpoint" {
  value = hcp_vault_cluster.hcp_vault.vault_public_endpoint_url
}

output "admin_token" {
  value = hcp_vault_cluster_admin_token.vault_token.token
  sensitive = true 
}

output "namespace" {
  value = hcp_vault_cluster.hcp_vault.namespace
}
