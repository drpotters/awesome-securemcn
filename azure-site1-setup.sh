#!/bin/bash
terraform -chdir=azure-site1 init
terraform -chdir=azure-site1 apply -auto-approve -var-file=../admin.auto.tfvars
