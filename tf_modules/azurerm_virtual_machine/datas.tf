data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "crowdstrikefalconid" {
  name         = var.falconid_key_vault_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "crowdstrikefalconcid" {
  name         = var.falconcid_key_vault_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "crowdstrikefalconsecret" {
  name         = var.falconsecret_key_vault_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_key" "sshkey" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
    if lower(vm.os_type) == "linux"
  }

  name         = each.value.key_vault_key_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "ado_pat" {
  for_each = {
    for vm in var.virtual_machine : vm.name => vm
    if var.enable_ado_agent == true
  }

  name         = each.value.ado_key_vault_secret_name
  key_vault_id = var.key_vault_id
}