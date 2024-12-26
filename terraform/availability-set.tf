
module "avd_availability_set" {
  source = "github.com/Coalfire-CF/ACE-Azure-VM-AvailabilitySet?ref=v1.0.0"

  availability_set_name = "${local.resource_prefix}-avd-as"
  location              = var.location
  resource_group_name   = data.terraform_remote_state.setup.outputs.management_rg_name
  regional_tags         = var.regional_tags
  global_tags           = var.global_tags
}