variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "private_connection_resource_id" {
  type = string
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "subresource_names" {
  type    = list(string)
  default = null
}