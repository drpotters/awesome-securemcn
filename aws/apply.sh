terraform apply -auto-approve -var-file=../admin.auto.tfvars \
    -var buildSuffix=`terraform -chdir=.. output -json | jq -r .buildSuffix.value` \
    -var f5xcVirtualSite=`terraform -chdir=.. output -json | jq -r .f5xcVirtualSite.value` \
    -var commonClientIP=`terraform -chdir=.. output -json | jq -r .commonClientIP.value`
