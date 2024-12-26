<!-- markdownlint-disable first-line-h1 -->
## Overview

The module provides an option to deploy [Azure Virtual Machine.][alz_management].

This brings the benefit of being able to manage the full lifecycle of these resources using Terraform.

## Resource types

When you enable deployment of Azure Virtual Machine, the module deploys and manages the following resource types (*depending on configuration*):

| Resource | Azure resource type | Terraform resource type |
| --- | --- | --- |
| Random String | **[`Terraform`][random_string]** | **[`random_string`][random_string]** |
| Azure Network Interface | **[`Microsoft.Network/networkInterfaces`][arm_network_interface]** | **[`azurerm_network_interface`][azurerm_network_interface]** |
| Azure Linux Virtual Machine | **[`Microsoft.Compute/virtualMachines`][arm_linux_virtual_machine]** | **[`azurerm_linux_virtual_machine`][azurerm_linux_virtual_machine]** |
| Azure Windows Virtual Machine | **[`Microsoft.Compute/virtualMachines`][arm_windows_virtual_machine]** | **[`azurerm_windows_virtual_machine`][azurerm_windows_virtual_machine]** |
| Azure Virtual Machine Extension | **[`Microsoft.Compute/virtualMachines/extensions`][arm_virtual_machine_extension]** | **[`azurerm_virtual_machine_extension`][azurerm_virtual_machine_extension]** |



## Usage and Example Configuration
### variables.tf
```hcl
variable "location" {
  type = string
}

variable "enable_ado_agent" {
  type    = bool
  default = false
}

variable "ado_organization_url" {
  type    = string
  default = null
}

variable "ado_project_name" {
  type    = string
  default = null
}

variable "ado_agent_pool_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "admin_username" {
  type    = string
  default = "hangeradmin"
}

variable "subnet_id" {
  type = string
}

variable "virtual_machine" {
  type = any
}
```

### main.tf
```hcl
module "virtual_machine" {
  source = "git::https://Hanger-Infrastructure@dev.azure.com/Hanger-Infrastructure/Infra-as-Code/_git/TerraformTemplates//azurerm_virtual_machine"

  location             = var.location
  tags                 = var.tags
  admin_username       = var.admin_username
  enable_ado_agent     = true # If this is set to true, please fill the next three attribute below ado_organization_url,ado_project_name, ado_agent_pool_name or else remove them.

  ado_organization_url = "https://dev.azure.com/Hanger-Infrastructure" # Remove line if enable_ado_agent is set to false
  ado_project_name     = "Infra-as-Code" # Remove line if enable_ado_agent is set to false
  ado_agent_pool_name  = "Hanger-Infrastructure-Agent-Pools" # Remove line if enable_ado_agent is set to false
  subnet_id            = var.subnet_id
  virtual_machine      = var.virtual_machine
}
```

### terraform.auto.tfvars
```hcl
location                   = "centralus"
admin_username             = "hangeradmin"
subnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<resource group name>/providers/Microsoft.Network/virtualNetworks/<virtual network name>/subnets/<subnet name>"
log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<resource group name>/providers/Microsoft.OperationalInsights/workspaces/<workspace name>"

# Please follow the Hanger cloud naming convention
virtual_machine = [
  # Below configuration is for Linux Server
  {
    resource_group_name = "resource group name"
    name                = "virtual machine name"
    size                  = "VM size" # Example: Standard_D4s_v3
    os_type               = "linux"
    key_vault_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<resource group name>/providers/Microsoft.KeyVault/vaults/<key vault name>" # This is required for ssh key
    key_vault_key_name    = "ssh key key name"
    source_image_reference = [
      {
        publisher = "RedHat"
        offer     = "RHEL"
        sku       = "810-gen2"
        version   = "latest"
      }
    ]
  },
  # Below configuration is for Windows Server
  {
    resource_group_name = "resource group name"
    name                = "virtual machine name"
    size                  = "VM size" # Example: Standard_D4s_v3
    os_type               = "windows"
    //license_type          = "RHEL_BYOS"
    source_image_reference = [
      {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition"
        version   = "latest"
      }
    ]
  }
]
```

### Module Attributes
#### NOTE: Module attributes and values are listed below with the required variables marked with the bold fonts.
#### Top Level Attributes
| Module Attributes | Data Type | Example Value |
| --- | --- | --- |
| **location** | ***string*** | **central** |
| **admin_username** | ***string*** | **Virtual administrator user name** |
| **tags** | ***map(string)*** | **Resource tags** |
| **subnet_id** | ***string*** | **/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resource group name/providers/Microsoft.Network/virtualNetworks/virtual network name/subnets/subnet name** |
| **log_analytics_workspace_id** | ***string*** | **/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resource group name/providers/Microsoft.OperationalInsights/workspaces/workspace name** |
| **virtual_machine** | ***list(object)*** | **See *terraform.auto.tfvars* file above under usage and example configuration for details** |


#### Virtual Machine Object Attributes

| Module Attributes | Data Type | Example Value |
| --- | --- | --- |
| **name** | ***string*** | **Virtual machine name** |
| **resource_group_name** | ***string*** | **Virtual machine resource group name** |
| **size** | ***string*** | **Standard_D4s_v3** |
| **os_type** | ***string*** | **windows or linux** |
| **source_image_reference** | ***string*** | **windows or linux source image reference. See *terraform.auto.tfvars* file above** |
| key_vault_id | *string* | null |
| key_vault_key_name | *string* | linuxvm-sshkey |
| key_vault_secret_name | *string* | adoagent-Pat |
| license_type | *string* | null |
| caching | *string* | ReadWrite" |
| storage_account_type | *string* | Standard_LRS |
| source_image_id | *string* | null |
| private_ip_address | *string* | null |
| encryption_at_host_enabled | *bool* | true |
| patch_assessment_mode | *string* | ImageDefault |
| private_ip_address_allocation | *string* | Dynamic |
| accelerated_networking_enabled | *bool* | true |
| disable_password_authentication | *bool* | true |


 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

 [//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)


[alz_management]:                    https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines
[random_string]:                     https://registry.terraform.io/providers/hashicorp/random/latest/string
[arm_network_interface]:             https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networkinterfaces
[arm_linux_virtual_machine]:         https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines
[arm_windows_virtual_machine]:       https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines
[arm_virtual_machine_extension]:     https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/extensions

[random_string]:                     https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
[azurerm_network_interface]:         https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
[azurerm_linux_virtual_machine]:     https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
[azurerm_windows_virtual_machine]:   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
[azurerm_virtual_machine_extension]: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension


<br>
<br>
Copyright: © 2024 Hanger Clinic Inc<br>
Author: Micheal Falowo<br>
This software is protected under copyright law.  Any unauthorized use, reproduction, or distribution of this code is strictly prohibited.*