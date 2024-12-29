output "vm_password" {
    value = random_password.vm_password.result
    sensitive = true
}
output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}





