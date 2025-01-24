## Packer and HCP Vault Better Together. See how you can codify your HCP Vault, a managed option for running Vault in the Cloud and securing all your Secrets and Cloud Credentials. This will make your Pipeline more reliable and secure!

Push Secrets with Button. This will make your CI/CD Pipeline more secure and your credentials will not be spread across multiple environments or repos to be used in GitHub Actions. This is could be a concern if number of pipelines and repos increases. 

This demo is showing you how to create HCP Vault with Terraform Code and configuring a management workspace for your HCP Vault Instance which is needed for your GitHub Actions Pipeline(GHA). The Demo Setup configures Auth Engines, Secret Engines and Policies in order to dynamically provision AWS Credentials with Least Privilege Principals for each packer build run for your golden image pipeline or whatever pipeline you are considering. The Pipeline is build with Github Actions and leverages [Vault Actions Template](https://github.com/hashicorp/vault-action) officially maintaned by HashiCorp. 

## General Information
- What is [Terraform Cloud?](https://cloud.hashicorp.com/products/terraform)
- What is [HCP Vault?](https://cloud.hashicorp.com/products/vault)
- What is [HCP Packer?](https://github.com/lomar92/hcp_packer_tfc_demo)

HCP Vault is currently supported for AWS. EU-Central-1 Frankfurt is available. 

If it is your first time with HCP Vault. Check out our [Learning Guide](https://learn.hashicorp.com/collections/vault/cloud)

##  Prerequisites
1. AWS Credentials.
2. HCP Secrets for HCP Vault and HCP Packer Registry. [Create an Account on HashiCorp Cloud Platform](https://portal.cloud.hashicorp.com/sign-in)
3. Terraform Cloud Account

### Set Up
1. Create Terraform Workspace **"vault-config"** with CLI Workflow. Set up your AWS Creds and HCP Secrets in your Variable sets. 
2. Change to directory **01.hcp-vault-cluster** and run following cmds. This will take some minutes until HCP Vault is up and running.

```shell
cd 01.hcp-vault-cluster
terraform init
terraform plan
terraform apply --auto-approve
```
3. Change to directory **02.configure-hcp-vault**
Create Workspace vault-management. Set up Secrets as Terraform variables in your workspace. This will be needed to configure secrets engines. AWS Secrets will be needed for configuring AWS Secrets Engine in HCP Vault and HCP Secrets for configuring kv2 engine. Make sure you have AWS Creds with required Roles set up to make this run in your pipeline. [AWS Policy and Roles Setup](https://www.vaultproject.io/docs/secrets/aws). Change general settings of Remote State Sharing in your "vault-config" workspace and set to specific workspace **"vault-management"**

Have a look in main.tf for configuring your HCP Vault Instance. Vault provider fetches output data from your statefile of your workspace "vault-config". As a rule, you would have to configure the environment variables in the [Vault provider settings](https://registry.terraform.io/providers/hashicorp/vault/latest/docs#provider-arguments), but with this setting you do not have to set up.

```r
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
```


### Configuring GitHub OIDC/JWT Auth and AWS Secrets Engine in Vault
The configured Auth Engine does have root privileges. If you want to configure least privilege make sure to assign right policy in your terraform code. hcp-root policy is the default policy once you set up HCP Vault. Terraform Code creates a policy devops-secrets with read and list to desired path. Make sure when you clone it to change this if required. 

End of last year, Github made OIDC generally available for Github Actions. This means that you can configure your workflows to have access to auto-generated token and use it to request short-lived tokens from different providers that supports OIDC. This means more secure workflows as you no longer have to store the credentials as Github Secrets anymore. Before this change, the main authentication methods for Vault in Github have been the integrated Github authentication, Token, and AppRole. With these approaches excluding the Github authentication, you would still have to store credentials to Github Secrets to use them in workflows. Hashicorp Vault becomes your idenity broker for your CI/CD Pipelines in GitHub. 

```r
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
    sub : "repo:<orgname>/<repo>:ref:refs/*"
  }

  bound_audiences = ["https://github.com/<org>"]

  user_claim = "workflow"
  role_type  = "jwt"
  token_ttl  = "1800"
  namespace  = data.terraform_remote_state.vault_infra.outputs.namespace
  #  namespace  = vault_namespace.devops.path
}
```
### Let the Magic happen!
```shell
terraform apply
```

### Configure Github Actions Workflow Template 
Vault Action currently supports retrieving secrets from any engine where secrets are retrieved via GET requests. If you configured your AWS Dynamic Credentials do generate IAM Credentials plan to build a step to add a delay of 5-10 seconds after fetching secrets, because IAM credentials are eventually consistent with respect to other Amazon services. If you want to be able to use credentials without the wait, consider using the STS method of fetching keys. IAM credentials supported by an STS token are available for use as soon as they are generated.

If you want to change the credentials method to STS do not forget to change your settings for AWS Secrets Engine. 

### Start your Pipeline by commiting and pushing your changes
```shell
cd 03.packer
make some changes
git push 
```
Check the GHA Workflow under Actions. If everything is set up successfully your build process will be finish with no erros. 

## Links

Usefull links for your own Secure Golden Image CI Pipeline.
- [Hashitalks 2022 - Live Demo](https://www.youtube.com/watch?v=jz1h-bSPLOI)
- [GHA HashiCorp Vault](https://github.com/hashicorp/vault-action)
- [Terraform Vault Provider Documentation](https://registry.terraform.io/providers/hashicorp/vault/latest/docs#provider-arguments)
- [Configuring OpenID Connect in HashiCorp Vault](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault)
- [Learn to codify your HCP Vault Instance with Terraform](https://developer.hashicorp.com/vault/tutorials/cloud-ops/vault-codify-mgmt)
