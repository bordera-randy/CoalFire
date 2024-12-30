# This is the main.tf file that will be used to deploy the module

# Create the resource group
resource "azurerm_resource_group" "rg" {
    name                    = "${local.resource_prefix}-${local.iteration}-rg"
    location                = local.location
    tags                    = local.tags
}

# Create the Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
    name                = "${local.resource_prefix}-${local.iteration}-law"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "PerGB2018"
    retention_in_days   = 30
    tags                = local.tags
    depends_on = [ azurerm_resource_group.rg ]
}

# Create the Virtual Network using the CoalFire module
module "vnet" {
    source                  = "github.com/Coalfire-CF/terraform-azurerm-vnet"
    resource_group_name     = azurerm_resource_group.rg.name
    vnet_name               = "${local.resource_prefix}-${local.iteration}-vnet"
    address_space           = ["10.0.0.0/16"]
    tags                    = local.tags
    diag_log_analytics_id   = azurerm_log_analytics_workspace.law.id
    subnets                 = local.subnets
    depends_on = [ azurerm_resource_group.rg, azurerm_log_analytics_workspace.law ]
}


resource "azurerm_subnet" "subnet" {
  for_each             = local.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = try(each.value.subnet_service_endpoints, null)
  

  dynamic "delegation" {
    for_each = try(each.value.subnet_delegations, [])
    content {
      name = delegation.value

      service_delegation {
        name    = delegation.value
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
      }
    }
  }
}


# Create the storage account using the CoalFire module
module "storage" {
    source                          = "github.com/Coalfire-CF/terraform-azurerm-storage-account"
    resource_group_name             = azurerm_resource_group.rg.name
    name                            = "${replace(local.resource_prefix, "-", "")}${local.iteration}strg"
    diag_log_analytics_id           = azurerm_log_analytics_workspace.law.id
    account_kind                    = "StorageV2"
    account_tier                    = "Standard"
    location                        = local.location
    storage_containers              = ["terraformstate", "weblogs"]
    public_network_access_enabled   = true
    tags                            = local.tags
    depends_on                      = [ azurerm_resource_group.rg ]
}

resource "azurerm_storage_account_network_rules" "storage_network_rules" {
  storage_account_id            = module.storage.id
  default_action                = "Deny"
  virtual_network_subnet_ids    = [azurerm_subnet.subnet["management"].id]
}


# Create the availability set using the CoalFire module
module "availability_set" {
    source                  = "github.com/Coalfire-CF/terraform-azurerm-VM-AvailabilitySet"
    resource_group_name     = azurerm_resource_group.rg.name
    location                = local.location
    availability_set_name   = "${local.resource_prefix}-${local.iteration}-avset"
    global_tags             = local.tags
    regional_tags           = local.tags
    depends_on              = [azurerm_resource_group.rg]
}

# Create the Key Vault using the CoalFire module
module "key_vault" {
    source                          = "github.com/Coalfire-CF/terraform-azurerm-key-vault"
    resource_group_name             = azurerm_resource_group.rg.name
    location                        = local.location
    kv_name                         = "${local.resource_prefix}-${local.iteration}-kv"
    tenant_id                       = local.tenant_id
    enabled_for_disk_encryption     = true
    enabled_for_deployment          = true
    enabled_for_template_deployment = true
    tags                            = local.tags
    diag_log_analytics_id           = azurerm_log_analytics_workspace.law.id
    global_tags                     = local.tags
    regional_tags                   = local.tags
    depends_on                      = [azurerm_resource_group.rg]
}

resource "azurerm_role_assignment" "key_vault_secrets_officer" {
    scope                = module.key_vault.key_vault_id
    role_definition_name = "Key Vault Secrets Officer"
    principal_id         = local.object_id
}

data "azurerm_client_config" "current" {}
# Create the virtual machines without using a module
resource "azurerm_linux_virtual_machine" "vm" {
    count                 = 2
    name                  = "${local.resource_prefix}-${local.iteration}-vm-${count.index + 1}"
    resource_group_name   = azurerm_resource_group.rg.name
    location              = local.location
    size                  = "Standard_DS1_v2"
    availability_set_id   = module.availability_set.availability_set_id
    network_interface_ids = [azurerm_network_interface.vm_nic[count.index].id]
    admin_username        = "adminuser"
    admin_ssh_key {
        username   = "adminuser"
        public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
    disable_password_authentication = true

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
    provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = azapi_resource_action.ssh_public_key_gen.output.privateKey
      host        = azurerm_public_ip.vm_public_ip[count.index].ip_address
    }

    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y"
    ]
    }
    tags = local.tags
}

# Create Public IPs for the VMs
resource "azurerm_public_ip" "vm_public_ip" {
    count               = 2
    name                = "${local.resource_prefix}-${local.iteration}-vm-pip-${count.index + 1}"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
    tags                = local.tags
}

resource "azurerm_network_interface" "vm_nic" {
    count               = 2
    name                = "${local.resource_prefix}-${local.iteration}-nic-${count.index + 1}"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet["web"].id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.vm_public_ip[count.index].id
    }

    tags = local.tags
}

# Create Public IP for the Management VM
resource "azurerm_public_ip" "manage_vm_public_ip" {
    name                = "${local.resource_prefix}-${local.iteration}-manage-vm-pip"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
    tags                = local.tags
}

resource "azurerm_network_interface" "manage_vm_nic" {
    name                = "${local.resource_prefix}-${local.iteration}-nic-3"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet["management"].id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.manage_vm_public_ip.id
    }

    tags = local.tags
}
# Create Management Virtual Machine 

# Create the virtual machines without using a module
resource "azurerm_linux_virtual_machine" "manage_vm" {
    name                  = "${local.resource_prefix}-${local.iteration}-vm-3"
    resource_group_name   = azurerm_resource_group.rg.name
    location              = local.location
    size                  = "Standard_DS1_v2"
    network_interface_ids = [azurerm_network_interface.manage_vm_nic.id]
    admin_username        = "adminuser"
    admin_ssh_key {
        username   = "adminuser"
        public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
    disable_password_authentication = true

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    tags = local.tags
}

# Create a Network Security Group for the web subnet
resource "azurerm_network_security_group" "web_nsg" {
    name                = "${local.resource_prefix}-${local.iteration}-web-nsg"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name
    tags                = local.tags
}

# Allow SSH from the management subnet to the web subnet
resource "azurerm_network_security_rule" "allow_ssh_from_management" {
    name                        = "AllowSSHFromManagement"
    resource_group_name         = azurerm_resource_group.rg.name
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = azurerm_subnet.subnet["management"].address_prefixes[0]
    destination_address_prefix  = "*"
    network_security_group_name = azurerm_network_security_group.web_nsg.name
}

# Associate the NSG with the web subnet
resource "azurerm_subnet_network_security_group_association" "web_subnet_nsg" {
    subnet_id                 = azurerm_subnet.subnet["web"].id
    network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# Create a Network Security Group for the management subnet
resource "azurerm_network_security_group" "management_nsg" {
    name                = "${local.resource_prefix}-${local.iteration}-management-nsg"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name
    tags                = local.tags
}

# Allow SSH from a single IP to the management subnet
resource "azurerm_network_security_rule" "allow_ssh_from_ip" {
    name                        = "AllowSSHFromIP"
    resource_group_name         = azurerm_resource_group.rg.name
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "203.0.113.0"  # Replace with the actual IP
    destination_address_prefix  = "*"
    network_security_group_name = azurerm_network_security_group.management_nsg.name
}

# Associate the NSG with the management subnet
resource "azurerm_subnet_network_security_group_association" "management_subnet_nsg" {
    subnet_id                 = azurerm_subnet.subnet["management"].id
    network_security_group_id = azurerm_network_security_group.management_nsg.id
}

# Create a Public IP for the Load Balancer
resource "azurerm_public_ip" "web_lb_public_ip" {
    name                = "${local.resource_prefix}-${local.iteration}-web-lb-pip"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
    tags                = local.tags
}


# Create the Azure Load Balancer
resource "azurerm_lb" "web_lb" {
    name                = "${local.resource_prefix}-${local.iteration}-web-lb"
    location            = local.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "Standard"
    frontend_ip_configuration {
        name                 = "PublicIPAddress"
        public_ip_address_id = azurerm_public_ip.web_lb_public_ip.id
    }
    tags                = local.tags
}

# Create the Backend Address Pool
resource "azurerm_lb_backend_address_pool" "web_lb_backend_pool" {
    name                = "${local.resource_prefix}-${local.iteration}-web-lb-backend-pool"
    loadbalancer_id     = azurerm_lb.web_lb.id
}

# Create the Load Balancer Probe for HTTP
resource "azurerm_lb_probe" "http_probe" {
    name                = "${local.resource_prefix}-${local.iteration}-http-probe"
    loadbalancer_id     = azurerm_lb.web_lb.id
    protocol            = "Http"
    port                = 80
    request_path        = "/"
    interval_in_seconds = 5
    number_of_probes    = 2
}

# Create the Load Balancer Probe for HTTPS
resource "azurerm_lb_probe" "https_probe" {
    name                = "${local.resource_prefix}-${local.iteration}-https-probe"
    loadbalancer_id     = azurerm_lb.web_lb.id
    protocol            = "Https"
    port                = 443
    request_path        = "/"
    interval_in_seconds = 5
    number_of_probes    = 2
}

# Create the Load Balancer Rule for HTTP
resource "azurerm_lb_rule" "http_lb_rule" {
    name                            = "${local.resource_prefix}-${local.iteration}-http-lb-rule"
    loadbalancer_id                 = azurerm_lb.web_lb.id
    protocol                        = "Tcp"
    frontend_port                   = 80
    backend_port                    = 80
    frontend_ip_configuration_name  = "PublicIPAddress"
    probe_id                        = azurerm_lb_probe.http_probe.id
    backend_address_pool_ids        = [azurerm_lb_backend_address_pool.web_lb_backend_pool.id]
}

# Create the Load Balancer Rule for HTTPS
resource "azurerm_lb_rule" "https_lb_rule" {
    name                            = "${local.resource_prefix}-${local.iteration}-https-lb-rule"
    loadbalancer_id                 = azurerm_lb.web_lb.id
    protocol                        = "Tcp"
    frontend_port                   = 443
    backend_port                    = 443
    frontend_ip_configuration_name  = "PublicIPAddress"
    probe_id                        = azurerm_lb_probe.https_probe.id
    backend_address_pool_ids        = [azurerm_lb_backend_address_pool.web_lb_backend_pool.id]
}

# Associate the VMs with the Backend Address Pool
resource "azurerm_network_interface_backend_address_pool_association" "vm_nic_lb_association" {
    count                    = 2
    network_interface_id     = azurerm_network_interface.vm_nic[count.index].id
    ip_configuration_name    = "internal"
    backend_address_pool_id  = azurerm_lb_backend_address_pool.web_lb_backend_pool.id
}

# Store the storage account key in Key Vault
resource "azurerm_key_vault_secret" "storage_account_key" {
    name         = "storage-account-key"
    value        = module.storage.primary_access_key
    content_type = "secure string"
    key_vault_id = module.key_vault.key_vault_id
    depends_on = [ azurerm_role_assignment.key_vault_secrets_officer ]
}


# Store the private key in Key Vault
resource "azurerm_key_vault_secret" "ssh_private_key" {
    name         = "ssh-private-key"
    value        = azapi_resource_action.ssh_public_key_gen.output.privateKey
    content_type = "ssh private key"
    key_vault_id = module.key_vault.key_vault_id
    depends_on   = [azurerm_role_assignment.key_vault_secrets_officer]
}