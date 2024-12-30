variable "vnet_name" {
  description = "Name of the vnet to create"
  type        = string
  default     = "acctvnet"
}



variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with VNet."
  type        = list(string)
  default     = []
}


variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)
  default     = {}
}

variable "route_tables_ids" {
  description = "A map of subnet name to Route table ids"
  type        = map(string)
  default     = {}
}


variable "regional_tags" {
  type        = map(string)
  description = "Regional level tags"
  default     = {}
}

variable "global_tags" {
  type        = map(string)
  description = "Global level tags"
  default     = {}
}

variable "private_dns_zone_id" {
  type        = string
  description = "The ID of the Private DNS Zone."
  default     = null
}

