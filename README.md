# awesome-securemcn

This project..
- Infra: Creates project prefix, unique id, and an enhanced firewall policy (using values that will later be discovered by F5 XC and provided by AWS) and predefined CIDR blocks in Azure and in GCP
- Infra: Creates a new AWS VPC & subnets
- Infra: Creates a new Azure resource group & VNET
- Infra: Creates a new GPC Network & subnets
- Infra: Connects all sites via L3 using an F5 XC global network as a backup and the site mesh group as the primary CE to CE path
- Infra: Creates & attaches a provider managed K8s cluster to the CE SLO subnet in each cloud provider. ***Intent**: the SLO can route to other public subnets having Internet access where existing clusters with ingress endpoints likely already exist.*
- Infra-ish: Deploy an F5 supported NGINX ingress controller in AWS
- Workload: Deploy cloud-provider ingress controllers in Azure and Aws
- Workload: Deploy a distributed app that's L3 routed using provider-specific custom coredns configmaps to steer connections across the environment. *This can be reworked to use other service discovery products like Consul and internal DNS*
- Workload: Add a public ingress point to the app via F5 XC RE using F5 XC DNS records managed service.

![Arcadia in F5XC-MCN-NetworkConnect](https://github.com/drpotters/awesome-securemcn/assets/8976466/fc2df73d-d8aa-41ac-abdc-7928513cae9b)

## Variables
Variable set to define in your Terraform Cloud workspace: 
| Variable | Type (terraform / env) + Description | 
| - | - | 
| app_domain | terraform - The DNS domain name that will be used as common parent generated DNS name of loadbalancers. Default is 'shared.acme.com'. | 
| awsAz1 | terraform - AWS Availability Zone #1 | 
| awsAz2 | terraform - AWS Availability Zone #2 | 
| awsRegion | terraform - AWS Region | 
| azureLocation | terraform - Azure Location | 
| commonClientIP | terraform - IP address for client management access to infra and clusters | 
| commonSiteLabels | terraform - A common collection of labels (tags) to be assigned to each CE Site | 
| f5xcCloudCredAWS | terraform - F5 XC Cloud Credential to use with AWS | 
| f5xcCloudCredAzure | terraform - F5 XC Cloud Credential to use with Azure | 
| f5xcCloudCredGCP | terraform - F5 XC Cloud Credential to use with GCP | 
| gcpProjectId | terraform - The GCP project id to use | 
| gcpRegion | terraform - GCP region where resouce will be deployed | 
| namespace | terraform - The namespace to use in the F5 XC tenant and for workloads in K8s clusters | 
| projectPrefix | terraform - The prefix assigned to resource names created in XC and public cloud | 
| use_private_registry | terraform - Whether to use an optional private docker registry to pull the app workload container images | 
| registry_username | terraform - Private docker registry acount username | 
| registry_password | terrafom - Private docker registry account password | 
| registry_email | terraform - Private docker registry account email address | 
| resourceOwner | terraform - Owner of the deployment, for tagging purposes | 
| ssh_id | terraform - An optional SSH key to log in to the F5 XC CE nodes | 
| xc_tenant | terraform - The F5 XC tenant to use | 
| ARM_CLIENT_ID | env - Azure Client ID | 
| ARM_CLIENT_SECRET | env - Azure Client Secret | 
| ARM_SUBSCRIPTION_ID | env - Azure Subscription ID | 
| ARM_TENANT_ID | env - Azure Tenant (entranet directory) ID | 
| AWS_ACCESS_KEY_ID | env - AWS Access Key ID | 
| AWS_SECRET_ACCESS_KEY | env - AWS Secret Access Key | 
| GOOGLE_CREDENTIALS | env - Credentials to access GCP service account (base64encoded JSON) | 
| VES_P12_PASSWORD | env - F5 XC certificate password | 
| VOLT_API_P12_FILE | env - F5 XC P12 certificate (Base64encoded) | 
| VOLT_API_URL | env - F5 XC tenant-specific API URL | 
| aws_cidr | terraform |
```
[{
    vpcCidr         = "10.1.0.0/16",
    publicSubnets   = ["10.1.10.0/24", "10.1.110.0/24"],
    sliSubnets      = ["10.1.20.0/24", "10.1.120.0/24"],
    workloadSubnets = ["10.1.30.0/24", "10.2.130.0/24"],
    privateSubnets  = ["10.1.52.0/24", "10.1.152.0/24"]
}]
```
| azure_cidr | terraform |
```
[{
      vnet = [{
        vnetCidr = "10.2.0.0/16"
      }],
      subnets = [{
        public              = "10.2.10.0/24"
        sli                 = "10.2.20.0/24"
        workload            = "10.2.30.0/24"
        AzureFirewallSubnet = "10.2.40.0/24"
        private             = "10.2.52.0/24"
      }]
  }]
```
| gcp_cidr | terraform |
```
[{
      network     = "", // GCP doesn't require a base network CIDR
      sli         = "10.3.0.0/16",
      slo         = "100.64.96.0/22",
      proxysubnet = "100.64.100.0/24"
}]
```
## Prerequisites
1. A subscription and owner privilege to each cloud provider: AWS, Azure, GCP
   ### AWS
   IAM user with programmatic access for Terraform (for use by both F5 XC and GitHub)
   ### Azure
   App Registration for Terraform (for use by both F5 XC and GitHub), with the subscription IAM Role of "Owner" and limited ability to assign the Network Contributor role as follows: [^1]
     1. Condition #1 Action: Create or update role assignments
        - Expression:
           Attribute source: **Request**  
           Attribute: **Role definition ID**  
           Operator: **ForAnyOfAnyValues:GuidEquals** (Value)  
           Name: **Network Contributor (BuiltInRole)**  
      2. Condition #2 Action: Delete a role assignment
         - Expression:
           Attribute source: **Request**  
           Attribute: **Role definition ID**  
           Operator: **ForAnyOfAnyValues:GuidEquals**  (Value)  
           Name: **Network Contributor (BuiltInRole)**  
   ### GCP
   Service Account for Terraform (for use by both F5 XC and GitHub) with the following IAM Roles
      - Compute Admin - *Create VM's*
      - Compute Network Admin - *Create networks & subnets*
      - Compute OS Admin Login - *Manage EKS cluster nodes*
      - Compute OS Login - *Automate provisioning of services in EKS cluster nodes*
      - DNS Administrator - *Only when needed to support internal DNS*
      - Logging Admin - *EKS cluster requirement*
      - Monitoring Admin - *EKS cluster requirement*
      - Security Admin - *Create network firewall policies*
      - Service Account Admin - *Create a unique service account to run EKS cluster nodes*
   ### F5 XC
   - Manually create cloud credential to use with AWS
   - Manually create cloud credentials to use with Azure
   - Manually create cloud credentials to use with GCP
   - Manually create Volterra API.P12

2. Terraform Cloud
- Terraform Cloud Account *to maintain State*
- Terraform Project
- Terraform Workspaces  
**Each workspace must be configured for local execution and with remote state sharing to all workspaces in the organization**
xcmcn-ce-root
xcmcn-ce-aws
xcmcn-ce-aws-eks
xcmcn-ce-nic
xcmcn-ce-azure
xcmcn-ce-azure-aks
xcmcn-ce-gcp
xcmcn-ce-gcp-gke

## Steps
1. Add all credential names and/or values to TFC globals variable set  
2. CLI Workflow  
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

[^1]: Necessary to allow the Azure Managed Identity created by Azure for the AKS cluster and kubelet node to create an internal load balanacer on the SLO/public subnet