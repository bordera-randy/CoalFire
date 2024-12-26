resource "azurerm_private_endpoint" "pe" {
  for_each                      = toset(var.subresource_names)
  name                          = "${local.name}-${each.value}pe"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "${local.name}-${each.value}pe-nic"
  tags                          = local.tags

  private_service_connection {
    name                           = "${local.name}-${each.value}pe"
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = [each.value]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = replace(split("/", var.private_dns_zone_id)[8], ".", "-")
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group,
      tags["created_date"]
    ]
  }
}