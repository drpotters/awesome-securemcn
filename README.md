# awesome-securemcn

This project..
- Infra: Creates project prefix, unique id, and an enhanced firewall policy (using values that will later be discovered by F5 XC and provided by AWS) and predefined CIDR blocks in Azure and in GCP
- Infra: Creates a new AWS VPC & subnets
- Infra: Creates a new Azure resource group & VNET
- Infra: Creates a new GPC Network & subnets
- Infra: Connects all sites via L3 using an F5 XC global network as a backup and the site mesh group as the primary CE to CE path
- Infra: Creates & attaches a managed K8s cluster to the CE SLO subnet in each cloud provider. ***Intent**: the SLO can route to other public subnets with Internet access where existing clusters likely exist.*
- Infra-ish: Deploys an F5 supported NGINX ingress controller in AWS
- Workload: Deploys cloud-provider ingress controllers in Azure and Aws
- Workload: Deploys a distributed app that's L3 routed using provider-specific custom coredns configmaps to steer connections across the environment. *This can be changed to work with other service discovery products like Consul and internal DNS*
- Workload: Adds a public ingress point to the app using F5 XC DNS records managed service.

Steps
1. Manually create cloud credentials in AWS
Add AWS credential to XC
2. Manually create cloud credentials in Azure
Add Azure credential to XC
3. Manually create cloud credentials in GCP
Add GCP credential to XC
4. Manually create Volterra API.P12
5. Add all credential names and/or values to TFC globals variable set
6. CLI Workflow
alias tfaa='tf apply -auto-approve'
alias tfda='tf destroy -auto-approve'
tfaa
cd aws && tfaa
cd eks && tfaa
cd ../../nic && tfaa
cd ../azure && tfaa
cd aks && tfaa
cd ../../gcp && tfaa
cd gke && tfaa
cd ../../workload
tfaa

Go to your app at `https://${app_domain}`

🤙🤟🍺🫖