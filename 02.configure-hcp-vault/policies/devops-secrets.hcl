#this could be a policy :) 
# List, create, update, and delete key/value secrets at secret/
path "cloud-secrets/*"
{
  capabilities = ["read", "list"]
}

#Read AWS Secrets for Github Actions
path "aws/*" {
  capabilities = ["read", "list"]
}