resource "azurerm_windows_virtual_machine" "windows" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
    if lower(vm.os_type) == "windows"
  }

  name                       = each.value.name
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = each.value.resource_group_name
  computer_name              = substr(replace(each.value.name, "-", ""), 0, 15)
  size                       = each.value.size
  license_type               = each.value.license_type
  admin_username             = var.admin_username
  admin_password             = random_string.random[each.value.name].result
  custom_data                = try(base64encode(each.value.custom_data), null)
  patch_assessment_mode      = each.value.patch_assessment_mode
  encryption_at_host_enabled = each.value.encryption_at_host_enabled

  network_interface_ids = [
    azurerm_network_interface.networkinterface[each.value.name].id
  ]

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  os_disk {
    name                 = "${each.value.name}-osdisk"
    caching              = each.value.caching
    storage_account_type = each.value.storage_account_type
  }

  source_image_id = each.value.source_image_reference == null ? null : each.value.source_image_id

  dynamic "source_image_reference" {
    for_each = each.value.source_image_reference

    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  dynamic "plan" {
    for_each = each.value.plan

    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  lifecycle {
    ignore_changes = [
      computer_name,
      patch_assessment_mode,
      identity,
      tags["backup"],
      tags["created_date"]
    ]
  }
}