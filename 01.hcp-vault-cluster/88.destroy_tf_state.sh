#!/bin/bash
set -o xtrace
#destroy vault settings with terraform
terraform destroy --auto-approve 

#delete all generated files
rm terraform.tfstate
rm -r .terraform
rm .terraform.lock.hcl
rm terraform.tfstate.backup
