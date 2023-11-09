#!/bin/bash
terraform -chdir=aws init -upgrade
terraform -chdir=aws apply -auto-approve -var-file=../admin.auto.tfvars
terraform -chdir=aws/eks init -upgrade
terraform -chdir=aws/eks apply -auto-approve -var-file=../../admin.auto.tfvars
