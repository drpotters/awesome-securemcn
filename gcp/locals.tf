locals {
    projectPrefix = data.tfe_outputs.root.values.projectPrefix
    buildSuffix = data.tfe_outputs.root.values.buildSuffix
    resourceOwner = data.tfe_outputs.root.values.resourceOwner
    commonClientIP = data.tfe_outputs.root.values.commonClientIP
    f5xcCloudCredGCP = data.tfe_outputs.root.values.f5xcCloudCredGCP
    namespace = data.tfe_outputs.root.values.namespace
    xc_tenant = data.tfe_outputs.root.values.xc_tenant

    gcpProjectId = data.tfe_outputs.root.values.gcpProjectId
    gcpRegion = data.tfe_outputs.root.values.gcpRegion
    gcp_cidr = data.tfe_outputs.root.values.gcp_cidr

    gcp_common_labels = merge(var.labels, {})
    volterra_common_labels = merge(var.labels, {
        platform = "gcp"
        demo     = "f5xc-mcn"
        owner    = local.resourceOwner
        prefix   = local.projectPrefix
        suffix   = local.buildSuffix
    })
    volterra_common_annotations = {
        source      = "git::https://github.com/F5DevCentral/f5-digital-customer-engangement-center"
        provisioner = "terraform"
    }
    
    # Service account names are predictable; use this to avoid dependencies
    // workstation_sa = format("%s-workstation-%s@%s.iam.gserviceaccount.com", var.projectPrefix, local.buildSuffix, var.gcpProjectId)
    // webserver_sa   = format("%s-webserver-%s@%s.iam.gserviceaccount.com", var.projectPrefix, local.buildSuffix, var.gcpProjectId)
    zones          = random_shuffle.zones.result

    clientIp = format("%s/32", data.http.ipinfo.response_body)
}