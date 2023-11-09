#!/bin/bash
terraform -chdir=gcp init
terraform -chdir=gcp apply -auto-approve -var-file=../admin.auto.tfvars