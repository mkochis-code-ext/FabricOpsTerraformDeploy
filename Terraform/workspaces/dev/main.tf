module "workspace" {
  source = "../../modules/workspace"

  display_name                   = var.workspace_display_name
  description                    = var.workspace_description
  capacity_id                    = var.capacity_id
  identity_type                  = var.identity_type
  skip_capacity_state_validation = var.skip_capacity_state_validation
}

# Connect the Dev workspace to the Azure DevOps repository. The workspace content
# is sourced from Git; the FabricDeploy_dev pipeline stage triggers Update From Git
# to pull the latest commit into the workspace.
resource "fabric_workspace_git" "this" {
  count = var.enable_git_integration ? 1 : 0

  workspace_id            = module.workspace.id
  initialization_strategy = var.git_initialization_strategy

  git_provider_details = {
    git_provider_type = "AzureDevOps"
    organization_name = var.git_organization_name
    project_name      = var.git_project_name
    repository_name   = var.git_repository_name
    branch_name       = var.git_branch_name
    directory_name    = var.git_directory_name
  }

  git_credentials = {
    source        = "ConfiguredConnection"
    connection_id = var.git_connection_id
  }
}
