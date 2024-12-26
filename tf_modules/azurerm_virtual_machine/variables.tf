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

variable "key_vault_id" {
  type = string
}

variable "falconid_key_vault_secret_name" {
  type    = string
  default = "crowdstrike-id"
}

variable "falconcid_key_vault_secret_name" {
  type    = string
  default = "crowdstrike-cid"
}

variable "falconsecret_key_vault_secret_name" {
  type    = string
  default = "crowdstrike-secret"
}


variable "subnet_id" {
  type = string
}

variable "virtual_machine" {
  type = list(object({
    resource_group_name             = string
    name                            = string
    size                            = string
    os_type                         = string
    key_vault_key_name              = optional(string, "linuxvm-sshkey")
    ado_key_vault_secret_name       = optional(string, "adoagent-Pat")
    license_type                    = optional(string, null)
    caching                         = optional(string, "ReadWrite")
    storage_account_type            = optional(string, "Standard_LRS")
    source_image_id                 = optional(string, null)
    private_ip_address              = optional(string, null)
    encryption_at_host_enabled      = optional(bool, true)
    patch_assessment_mode           = optional(string, "ImageDefault")
    private_ip_address_allocation   = optional(string, "Dynamic")
    accelerated_networking_enabled  = optional(bool, true)
    disable_password_authentication = optional(bool, true)

    source_image_reference = optional(list(object({
      publisher = optional(string)
      offer     = optional(string)
      sku       = optional(string)
      version   = optional(string, "latest")
    })), [])

    plan = optional(list(object({
      name      = optional(string)
      product   = optional(string)
      publisher = optional(string)
    })), [])
  }))
}