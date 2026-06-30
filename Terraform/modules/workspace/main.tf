resource "fabric_workspace" "this" {
  display_name                   = var.display_name
  description                    = var.description
  capacity_id                    = var.capacity_id
  skip_capacity_state_validation = var.skip_capacity_state_validation

  identity = var.identity_type == null ? null : {
    type = var.identity_type
  }
}

# Grant an Entra security group the Admin role on the workspace so designated
# users retain full control of deployed content independently of the pipeline SP.
resource "fabric_workspace_role_assignment" "admin_group" {
  count = var.admin_group_id == null ? 0 : 1

  workspace_id = fabric_workspace.this.id
  role         = "Admin"

  principal = {
    id   = var.admin_group_id
    type = "Group"
  }
}
