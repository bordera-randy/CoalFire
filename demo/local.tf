# network 
locals {
  tenant_id = "76195987-c9c2-4822-8771-4c31d24951a5"
  object_id = "3454362e-1e15-4731-9ec3-6bab4be4bacd"
  resource_prefix = "uc-poc-coalfire"
  iteration = "24"
  public_ip_to_whitelist = "170.85.100.119"
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
      address_prefix = "10.0.1.0/24"
    }
    management = {
      name       = "${local.resource_prefix}-management-sn-1"
      address_prefix = "10.0.2.0/24"
      subnet_service_endpoints = ["Microsoft.Storage"]
    }
    backend = {
      name       = "${local.resource_prefix}-backend-sn-1"
      address_prefix = "10.0.3.0/24"
    }
    web = {
      name       = "${local.resource_prefix}-web-sn-1"
      address_prefix = "10.0.4.0/24"
    }
    azurerm_bastion_host = {
      name       = "AzureBastionSubnet"
      address_prefix = "10.0.5.0/24"
    }
  }
}

