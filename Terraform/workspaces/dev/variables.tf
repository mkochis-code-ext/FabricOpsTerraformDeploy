# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------
variable "tenant_id" {
  description = "Entra ID tenant ID used to authenticate to Fabric. Can also be set via FABRIC_TENANT_ID."
  type        = string
  default     = null
}

variable "client_id" {
  description = "Service principal client ID used to authenticate to Fabric. Can also be set via FABRIC_CLIENT_ID."
  type        = string
  default     = null
}

variable "use_oidc" {
  description = "Use OIDC (Workload Identity Federation) for authentication. Recommended for Azure DevOps pipelines."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Workspace
# ---------------------------------------------------------------------------
variable "workspace_display_name" {
  description = "Display name of the Dev Fabric workspace."
  type        = string
  default     = "FabricOps-Dev"
}

variable "workspace_description" {
  description = "Description of the Dev Fabric workspace."
  type        = string
  default     = "Development workspace managed by Terraform."
}

variable "capacity_id" {
  description = "Fabric Capacity ID to assign to the workspace. Leave null for shared capacity."
  type        = string
  default     = null
}

variable "identity_type" {
  description = "Workspace identity type ('SystemAssigned' or null)."
  type        = string
  default     = null
}

variable "skip_capacity_state_validation" {
  description = "Skip Fabric Capacity state validation when the caller cannot list capacities."
  type        = bool
  default     = false
}

variable "admin_group_id" {
  description = "Object ID of an Entra security group granted the Admin role on the workspace. Leave null to skip."
  type        = string
  default     = null
}
# The Dev workspace is connected to the ADO repo so its content is sourced
# from Git. Promotions to Non-Prod/Prod are handled by the deployment pipeline.
# ---------------------------------------------------------------------------
variable "enable_git_integration" {
  description = "Whether to connect the Dev workspace to an Azure DevOps Git repository."
  type        = bool
  default     = true
}

variable "git_connection_id" {
  description = "ID of the pre-created Fabric connection used for the ADO Git integration (ConfiguredConnection, required for service principal auth)."
  type        = string
  default     = null
}

variable "git_organization_name" {
  description = "Azure DevOps organization name backing the Dev workspace."
  type        = string
  default     = null
}

variable "git_project_name" {
  description = "Azure DevOps project name backing the Dev workspace."
  type        = string
  default     = null
}

variable "git_repository_name" {
  description = "Azure DevOps repository name backing the Dev workspace."
  type        = string
  default     = null
}

variable "git_branch_name" {
  description = "Azure DevOps branch the Dev workspace tracks."
  type        = string
  default     = null
}

variable "git_directory_name" {
  description = "Directory within the repository that holds the Fabric items. Must start with '/'."
  type        = string
  default     = "/Fabric"
}

variable "git_initialization_strategy" {
  description = "Initialization strategy when connecting Git. 'PreferRemote' seeds the workspace from Git; 'PreferWorkspace' seeds Git from the workspace."
  type        = string
  default     = "PreferRemote"

  validation {
    condition     = contains(["PreferRemote", "PreferWorkspace"], var.git_initialization_strategy)
    error_message = "git_initialization_strategy must be 'PreferRemote' or 'PreferWorkspace'."
  }
}
