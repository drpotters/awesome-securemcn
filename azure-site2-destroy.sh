#!/bin/bash
terraform -chdir=azure-site2 destroy -var-file=../admin.auto.tfvars \
    -var buildSuffix=`terraform output -json | jq -r .buildSuffix.value` \
    -var f5xcVirtualSite=`terraform output -json | jq -r .f5xcVirtualSite.value`
