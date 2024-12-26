<!-- markdownlint-disable first-line-h1 -->
## Overview

The module provides an option to deploy [Azure Virtual Network.][alz_management].

This brings the benefit of being able to manage the full lifecycle of these resources using Terraform.

## Resource types

When you enable deployment of Azure Virtual Network, the module deploys and manages the following resource types (*depending on configuration*):

| Resource | Azure resource type | Terraform resource type |
| --- | --- | --- |
| Azure Virtual Network | **[`Microsoft.Network/virtualNetwork`][arm_virtual_network]** | **[`azurerm_virtual_network`][azurerm_virtual_network]** |
| Azure Virtual Network Subnet | **[`Microsoft.Network/virtualNetwork/subnets`][arm_subnet]** | **[`azurerm_subnet`][azurerm_subnet]** |
| Azure Monitor Diagnostic Setting | **[`Microsoft.Insights/diagnosticSettings`][arm_monitor_diagnostic_setting]** | **[`azurerm_monitor_diagnostic_setting`][azurerm_monitor_diagnostic_setting]** |


## Usage and Example Configuration
### variables.tf
```hcl
variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "virtual_network" {
  type    = any
}
```

### main.tf
```hcl
module "network" {
  source   = "git::https://Hanger-Infrastructure@dev.azure.com/Hanger-Infrastructure/Infra-as-Code/_git/TerraformTemplates//azurerm_virtual_network"
  location = var.location

  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags

  virtual_network = try(var.virtual_network[terraform.workspace], {})
}
```

### terraform.auto.tfvars
```hcl
location                   = "centralus"
resource_group_name        = "uc-dev-test-01-rg"
log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<resource group name>/providers/Microsoft.OperationalInsights/workspaces/<workspace name>"
tags                       = {}

virtual_network = {
  dev = {
    name          = "uc-dev-test-01-vnet"
    address_space = ["10.200.0.0/16"]
    subnets = [
      {
        name             = "apimanagement"
        address_prefixes = ["10.200.0.0/24"]
      },
      {
        name             = "compute"
        address_prefixes = ["10.200.1.0/24"]
      },
      {
        name             = "vnet-integration"
        address_prefixes = ["10.200.2.0/24"]
        delegations = [
          {
            name = "delegation"
            service_delegation = {
              name    = "Microsoft.Web/serverFarms"
              actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
            }
          }
        ]
      }
    ]
  }
}
```

### Module Attributes
#### NOTE: Module attributes and values are listed below with the required variables marked with the bold fonts.
#### Top Level Attributes
| Module Attributes | Data Type | Example Value |
| --- | --- | --- |
| **location** | ***string*** | **central** |
| **tags** | ***map(string)*** | **Resource tags** |
| **log_analytics_workspace_id** | ***string*** | **/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resource group name/providers/Microsoft.OperationalInsights/workspaces/workspace name** |
| **virtual_network** | ***object*** | **See *terraform.auto.tfvars* file above under usage and example configuration for details** |


#### Virtual Network Object Attributes
| Module Attributes | Data Type | Example Value |
| --- | --- | --- |
| **resource_group_name** | ***string*** | **Virtual Network resource group name** |
| **name** | ***string*** | **Virtual Network name** |
| **address_space** | ***list(string)*** | **Virtual Network address space [ "10.0.0.0/16" ]** |
| **subnets** | ***list(object)*** | **See *terraform.auto.tfvars* file above under usage and example configuration for details** |
| dns_servers | *list(string)* | Virtual Network dns server IPs [ "10.0.0.4", "10.0.0.5" ] |
| ddos_protection_plan_id | *string* | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resource group name/providers/Microsoft.Network/ddosProtectionPlans/ddos protection plan name |


#### SubnetObject Attributes
| Module Attributes | Data Type | Example Value |
| --- | --- | --- |
| **name** | ***string*** | **Virtual Network name** |
| **address_prefixes** | ***list(string)*** | **Subnet address prefix [ "10.0.1.0/24" ]** |
| delegations | *any* | Subnet delegations. See *terraform.auto.tfvars* file above under usage and example configuration for details |
| service_endpoints | *list(string)* | Subnet service endpoints |
| private_endpoint_network_policies | *string* | Enabled/Disabled |
| private_link_service_network_policies_enabled | *bool* | true/false |



 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

 [//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)


[alz_management]:                       https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/virtualnetworks
[arm_virtual_network]:                  https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/virtualnetworks
[arm_subnet]:                           https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/virtualnetworks/subnets
[arm_monitor_diagnostic_setting]:       https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/diagnosticSettings


[azurerm_virtual_network]:              https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
[azurerm_subnet]:                       https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
[azurerm_monitor_diagnostic_setting]:   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting


<br>
<br>
Copyright: © 2024 Hanger Clinic Inc<br>
Author: Micheal Falowo<br>
This software is protected under copyright law.  Any unauthorized use, reproduction, or distribution of this code is strictly prohibited.