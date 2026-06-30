variable "display_name" {
  description = "The Workspace display name. Must be unique across the tenant and at most 256 characters."
  type        = string
}

variable "description" {
  description = "The Workspace description."
  type        = string
  default     = ""
}

variable "capacity_id" {
  description = "The ID of the Fabric Capacity to assign to the Workspace. Leave null to use shared capacity."
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The workspace identity type. Set to 'SystemAssigned' to enable a workspace identity, or null to disable."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || var.identity_type == "SystemAssigned"
    error_message = "identity_type must be either null or 'SystemAssigned'."
  }
}

variable "skip_capacity_state_validation" {
  description = "Whether to skip the Fabric Capacity state validation. Useful when the caller cannot list capacities."
  type        = bool
  default     = false
}
