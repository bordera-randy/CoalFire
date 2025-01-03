output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}
output "web_vm_01_name" {
    value = azurerm_linux_virtual_machine.vm[0.0].name
}
output "web_vm_02_name" {
    value = azurerm_linux_virtual_machine.vm[0.0].name
}
output "management_vm_name" {
    value = azurerm_linux_virtual_machine.manage_vm.name
}
output "Log_Analytics_Workspace" {
    value = azurerm_log_analytics_workspace.law.name
}
output "key_data" {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}

output "Load_Balancer" {
    value = azurerm_lb.web_lb.name
}

output "virtual_network" {
    value = "${local.resource_prefix}-${local.iteration}-vnet"
}
