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
  description = "Display name of the Non-Prod Fabric workspace."
  type        = string
  default     = "FabricOps-NonProd"
}

variable "workspace_description" {
  description = "Description of the Non-Prod Fabric workspace."
  type        = string
  default     = "Non-production workspace managed by Terraform."
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
