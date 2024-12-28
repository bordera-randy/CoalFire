# network 
locals {
  resource_prefix = "uc-poc-coalfire"
  iteration = "01"
  location = "Central US"
  network_cidr_blocks = "10.0.0.0/16"
  tags = {
    infra_environment = "POC"
    purpose     = "Coalfire"
    owner       = "Randy Bordeaux"
    cost_center = "POC"
  }
  subnets = {
    application = {
      name       = "${local.resource_prefix}-application-sn-1"
      address_prefix = "10.0.0.0/24"
    }
    management = {
      name       = "${local.resource_prefix}-management-sn-1"
      address_prefix = "10.0.11.0/24"
      subnet_service_endpoints = ["Microsoft.Storage"]
    }
    backend = {
      name       = "${local.resource_prefix}-backend-sn-1"
      address_prefix = "10.0.12.0/24"
    }
    web = {
      name       = "${local.resource_prefix}-web-sn-1"
      address_prefix = "10.0.13.0/24"
    }
  }
}

