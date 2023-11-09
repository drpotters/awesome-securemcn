#Project Globals
variable "admin_src_addr" {
  type        = string
  description = "Allowed Admin source IP prefix"
  default     = "0.0.0.0/0"
}
#TF Cloud
variable "tf_cloud_organization" {
  type = string
  description = "TF cloud org (Value set in TF cloud)"
}
#AWS
variable "aws_access_key" {
  description = "AWS API Programmatic Access Key"
  type = string
  default = ""
}
variable "aws_access_secret" {
  description = "AWS API Programmatic Key Secret"
  type = string
  default = ""
}
variable "vpcid" {
  description = "AWS VPC to use for the EKS cluster and subnets"
  type = string
  default = ""
}
variable "route_table_id" {
  description = "The route table id to attach to the external EKS subnets"
  type        = string
  default     = ""
}
variable "eks_addons" {
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "kube-proxy"
      version = "v1.23.13-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.12.0-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.7-eksbuild.3"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.13.0-eksbuild.3"
    }
  ]
}
variable "ssh_key" {
  type        = string
  default     = null
  description = "Unneeded for EKS, only present for warning handling with TF cloud variable set"
}

variable "commonClientIP" {
  type        = string
  default     = null
  description = "Client IP is used for security access groups"
}
variable "buildSuffix" {
  type        = string
  default     = null 
  description = "unique build suffix for resources; will be generated if empty or null"
} 
variable "awsAz1" {
  description = "Availability Zone #"
  type        = string
  default = "az1"
}
variable "awsAz2" {
  description = "Availability Zone #"
  type        = string
  default = "az2"
}
variable "vpcId" {
  description = "AWS VPC ID"
  type = string
  default = null
}
variable "awsRegion" {
  description = "Name of the AWS region to deploy in"
  type = string
  
}

# Other variables from ../..check "name"
variable "projectPrefix" {
  type        = string
  description = "projectPrefix name for tagging"
}
variable "resourceOwner" {
  type        = string
  description = "Owner of the deployment for tagging purposes"
}
variable privateSubnets {
  description = "AWS Subnets eks-internal"
  type        = list(any)
  default     = ["10.1.40.0/24", "10.1.140.0/24"]
}