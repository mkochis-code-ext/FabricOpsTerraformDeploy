# Read each environment's workspace_id from its Terraform remote state.
# Only active environments referenced by a stage's source_environment are read.
data "terraform_remote_state" "env" {
  for_each = toset([
    for s in var.stages : s.source_environment
    if s.source_environment != null && contains(var.active_environments, s.source_environment)
  ])

  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name       = var.backend_container_name
    key                  = var.state_keys[each.value]
    use_oidc             = var.use_oidc
  }
}
