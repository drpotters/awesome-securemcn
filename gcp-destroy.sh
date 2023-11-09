#!/bin/bash
terraform -chdir=gcp destroy -auto-approve -var-file=../admin.auto.tfvars

# apply
