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
  type = object({
    resource_group_name     = string
    name                    = string
    address_space           = list(string)
    dns_servers             = optional(list(string), null)
    ddos_protection_plan_id = optional(string, null)
    subnets = optional(list(
      object({
        name                                          = string
        address_prefixes                              = list(string)
        private_endpoint_network_policies             = optional(string, "Disabled")
        private_link_service_network_policies_enabled = optional(bool, true)
        service_endpoints                             = optional(list(string), [])
        delegations                                   = optional(any, [])
      })
    ), [])
  })
}