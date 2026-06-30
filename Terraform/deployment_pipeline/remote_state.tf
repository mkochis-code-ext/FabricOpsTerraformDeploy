# Read each environment's workspace_id from its Terraform remote state.
# Only environments active on this run are read; grow-only environments that are already
# wired into the live pipeline reuse their existing workspace assignment instead.
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
    # Authenticate to the state storage account with Entra ID (RBAC) rather than
    # account keys, which are blocked by policy (listKeys is denied).
    use_azuread_auth     = true
  }
}
