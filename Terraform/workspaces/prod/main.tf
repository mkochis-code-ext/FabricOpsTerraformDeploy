module "workspace" {
  source = "../../modules/workspace"

  display_name                   = var.workspace_display_name
  description                    = var.workspace_description
  capacity_id                    = var.capacity_id
  identity_type                  = var.identity_type
  skip_capacity_state_validation = var.skip_capacity_state_validation
  admin_group_id                 = var.admin_group_id
}
