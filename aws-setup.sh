#!/bin/bash
terraform -chdir=aws init
terraform -chdir=aws apply -auto-approve -var-file=../admin.auto.tfvars
#terraform -chdir=aws/eks init
#terraform -chdir=aws/eks apply -auto-approve -var-file=../../admin.auto.tfvars