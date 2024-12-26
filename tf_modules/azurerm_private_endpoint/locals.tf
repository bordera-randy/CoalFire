locals {
  name = split("/", var.private_connection_resource_id)[8]

  local_tags = {
    "Environment"  = title(terraform.workspace)
    "created_date" = formatdate("YYYY-MM-DD", timestamp())
    "Managed_By"   = "Hanger Terraform IaC"
  }
  tags = merge(var.tags, local.local_tags)
}