#!/bin/bash
terraform -chdir=aws destroy -var-file=../admin.auto.tfvars
