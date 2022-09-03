variable "hvn_id" {
  description = "The ID of the HCP HVN."
  type        = string
  default     = "hcp-vault-hvn"
}

variable "cluster_id" {
  description = "The ID of the HCP Vault cluster."
  type        = string
  default     = "hcp-vault-cluster"
}

variable "peering_id" {
  description = "The ID of the HCP peering connection."
  type        = string
  default     = "vpc_peering"
}

variable "route_id" {
  description = "The ID of the HCP HVN route."
  type        = string
  default     = "hvn-route"
}

variable "region" {
  description = "The region of the HCP HVN and Vault cluster."
  type        = string
  default     = "eu-central-1"
}

variable "cloud_provider" {
  description = "The cloud provider of the HCP HVN and Vault cluster."
  type        = string
  default     = "aws"
}

variable "tier" {
  description = "Tier of the HCP Vault cluster. Valid options for tiers."
  type        = string
  default     = "dev"
}
