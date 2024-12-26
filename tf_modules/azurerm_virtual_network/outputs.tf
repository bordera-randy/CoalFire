output "virtual_network" {
  value = azurerm_virtual_network.vnet
}

output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnets" {
  value = {
    for subnet in azurerm_subnet.subnet : subnet.name => subnet
  }
}

output "subnets_id" {
  value = {
    for subnet in azurerm_subnet.subnet : subnet.name => subnet.id
  }
}