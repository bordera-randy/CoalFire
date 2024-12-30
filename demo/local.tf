# network 
locals {
  tenant_id = "76195987-c9c2-4822-8771-4c31d24951a5"
  object_id = "3454362e-1e15-4731-9ec3-6bab4be4bacd"
  resource_prefix = "uc-poc-coalfire"
  iteration = "16"
  location = "Central US"
  network_cidr_blocks = "10.0.0.0/16"
  tags = {
    infra_environment = "POC"
    purpose     = "Coalfire"
    owner       = "Randy Bordeaux"
    cost_center = "POC"
    app_environment = "Tech Challenge"
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

