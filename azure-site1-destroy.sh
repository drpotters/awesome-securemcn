#!/bin/bash
terraform -chdir=azure-site1 destroy -auto-approve -var-file=../admin.auto.tfvars
