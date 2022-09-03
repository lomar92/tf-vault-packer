#Namespace
variable "vault_namespace" {
  default = "devops"
}

#set AWS as TF Variables, not ENV in TFC
variable "AWS_ACCESS_KEY_ID" {
}

#set AWS Secret as TF Variables, not ENV in TFC
variable "AWS_SECRET_ACCESS_KEY" {
}

#SET HCP SECRETS as TF Variables, not ENV in TFC
variable "HCP_CLIENT_ID" {
}

variable "HCP_CLIENT_SECRET" {
}