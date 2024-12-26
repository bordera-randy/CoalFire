resource "random_string" "random" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
    if lower(vm.os_type) == "windows"
  }

  length           = 24
  special          = true
  override_special = "-_"
}

resource "azurerm_network_interface" "networkinterface" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
  }

  name                           = "${each.value.name}-nic"
  location                       = var.location
  tags                           = local.tags
  resource_group_name            = each.value.resource_group_name
  accelerated_networking_enabled = each.value.accelerated_networking_enabled

  ip_configuration {
    name                          = "ipConfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = try(each.value.private_ip_address_allocation, "Dynamic")
    private_ip_address            = try(each.value.private_ip_address_allocation, "Dynamic") != "Static" ? null : try(each.value.private_ip_address, "Dynamic")
  }

  lifecycle {
    ignore_changes = [
      ip_configuration,
      tags["created_date"]
    ]
  }
}

resource "azurerm_virtual_machine_extension" "linuxcrowdstrikeextension" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
    if var.enable_ado_agent == false && lower(vm.os_type) == "linux"
  }

  name                 = "CrowdstrikeFalconSensor${title(each.value.os_type)}"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux[each.value.name].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "fileUris": ["${local.linux_crowdstrike}"],
      "commandToExecute": "${local.linux_command}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      protected_settings
    ]
  }
}

resource "azurerm_virtual_machine_extension" "windowscrowdstrikeextension" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
    if var.enable_ado_agent == false && lower(vm.os_type) == "windows"
  }

  name                 = "CrowdstrikeFalconSensor${title(each.value.os_type)}"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows[each.value.name].id
  publisher            = "Microsoft.Compute"
  type                 = "customScriptExtension"
  type_handler_version = "1.10"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "fileUris": ["${local.windows_crowdstrike}"],
      "commandToExecute": "${local.windows_command}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      protected_settings
    ]
  }
}

resource "azurerm_virtual_machine_extension" "adoagentextension" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
    if var.enable_ado_agent == true
  }

  name                 = "TeamServicesAgentLinux"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux[each.value.name].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "script" : "${base64encode(templatefile("${path.module}/scripts/configure_linux_agent.sh", {
  AGENT_USER  = var.admin_username
  AGENT_POOL  = var.ado_agent_pool_name
  AGENT_TOKEN = data.azurerm_key_vault_secret.ado_pat[each.value.name].value
  AZDO_URL    = var.ado_organization_url
  REGION      = var.location
}))}"
    }
    PROTECTED_SETTINGS

lifecycle {
  ignore_changes = [
    protected_settings
  ]
}
}