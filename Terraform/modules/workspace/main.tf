resource "fabric_workspace" "this" {
  display_name                   = var.display_name
  description                    = var.description
  capacity_id                    = var.capacity_id
  skip_capacity_state_validation = var.skip_capacity_state_validation

  identity = var.identity_type == null ? null : {
    type = var.identity_type
  }
}
