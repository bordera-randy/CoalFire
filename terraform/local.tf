locals {
  network_cidr_blocks = "10.10.10.0/22"
  subnets = [
    "public-sn-1",
    "iam-sn-1",
    "cicd-sn-1",
    "secops-sn-1",
    "siem-sn-1",
    "monitor-sn-1",
    "bastion-sn-1",
    "AzureFirewallSubnet",
    "pe-sn-1",
    "psql-sn-1"
  ]

  subnet_configs = {
    "public-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    "iam-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    "cicd-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.ContainerRegistry"]
    }
    "secops-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    "siem-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    "monitor-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    "bastion-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    "AzureFirewallSubnet" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    "pe-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql", "Microsoft.ContainerRegistry"]
      enforce_private_link_endpoint_network_policies = true
    }
    "psql-sn-1" = {
      new_bits = 8
      subnet_service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
      subnet_delegations = {
        "Microsoft.DBforPostgreSQL/flexibleServers" = ["Microsoft.Sql"]
      }
      enforce_private_link_endpoint_network_policies = true
    }
  }
}
