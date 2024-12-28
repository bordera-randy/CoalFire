output "vm_password" {
    value = random_password.vm_password.result
    sensitive = true
}
output "vm_id" {
    value = azurerm_virtual_machine.vm.id
}

output "vm_name" {
    value = azurerm_virtual_machine.vm.name
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}





