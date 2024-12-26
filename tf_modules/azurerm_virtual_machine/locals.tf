locals {
  regions = {
    "centralus" = "uc"
  }

  local_tags = {
    "Environment"  = title(terraform.workspace)
    "created_date" = formatdate("YYYY-MM-DD", timestamp())
    "Managed_By"   = "Hanger Terraform IaC"
  }
  tags = merge(var.tags, local.local_tags)

  linux_crowdstrike   = "https://raw.githubusercontent.com/crowdstrike/falcon-scripts/main/bash/install/falcon-linux-install.sh"
  windows_crowdstrike = "https://raw.githubusercontent.com/CrowdStrike/falcon-scripts/main/powershell/install/falcon_windows_install.ps1"

  linux_command   = "export FALCON_CID=${data.azurerm_key_vault_secret.crowdstrikefalconcid.value} && export FALCON_CLIENT_ID=${data.azurerm_key_vault_secret.crowdstrikefalconid.value} && export FALCON_CLIENT_SECRET=${data.azurerm_key_vault_secret.crowdstrikefalconsecret.value} && /bin/bash falcon-linux-install.sh"
  windows_command = "powershell.exe -ExecutionPolicy Unrestricted -File falcon_windows_install.ps1 -FalconClientId ${data.azurerm_key_vault_secret.crowdstrikefalconid.value} -FalconClientSecret ${data.azurerm_key_vault_secret.crowdstrikefalconsecret.value} -FalconCid ${data.azurerm_key_vault_secret.crowdstrikefalconcid.value}"
}