#!/bin/bash
terraform -chdir=azure-site1/aks init -upgrade
terraform -chdir=azure-site1/aks apply -auto-approve -var-file=../../admin.auto.tfvars
