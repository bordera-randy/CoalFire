resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network.name
  location            = var.location
  tags                = local.tags
  resource_group_name = var.virtual_network.resource_group_name
  address_space       = var.virtual_network.address_space
  dns_servers         = var.virtual_network.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.virtual_network.ddos_protection_plan_id != null ? toset([split("/", var.virtual_network.ddos_protection_plan_id)[8]]) : []
    content {
      id     = var.virtual_network.ddos_protection_plan_id
      enable = true
    }
  }

  lifecycle {
    ignore_changes = [
      tags["created_date"]
    ]
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    for subnet in var.virtual_network.subnets : subnet.name => subnet
  }
  name                                          = each.value.name
  resource_group_name                           = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  service_endpoints                             = each.value.service_endpoints

  dynamic "delegation" {
    for_each = toset(each.value.delegations)
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  name                       = "${azurerm_virtual_network.vnet.name}-diag"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(local.logs)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(local.metrics)
    content {
      category = metric.value
    }
  }
}