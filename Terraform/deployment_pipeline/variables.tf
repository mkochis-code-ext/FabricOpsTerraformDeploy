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
# Remote state ingestion
# Used to read each environment's workspace_id output so the deployment pipeline
# stages can be wired up to the correct workspaces in a single run.
# ---------------------------------------------------------------------------
variable "backend_resource_group_name" {
  description = "Resource group of the Azure Storage account holding the environment Terraform state files."
  type        = string
}

variable "backend_storage_account_name" {
  description = "Azure Storage account name holding the environment Terraform state files."
  type        = string
}

variable "backend_container_name" {
  description = "Blob container holding the environment Terraform state files."
  type        = string
  default     = "tfstate"
}

variable "state_keys" {
  description = "Map of environment name to the blob key of its Terraform state file."
  type        = map(string)
  default = {
    dev     = "fabric/dev.tfstate"
    nonprod = "fabric/nonprod.tfstate"
    prod    = "fabric/prod.tfstate"
  }
}

# ---------------------------------------------------------------------------
# Deployment Pipeline
# ---------------------------------------------------------------------------
variable "deployment_pipeline_display_name" {
  description = "Display name of the Fabric deployment pipeline."
  type        = string
  default     = "FabricOps-Pipeline"
}

variable "deployment_pipeline_description" {
  description = "Description of the Fabric deployment pipeline."
  type        = string
  default     = "Deployment pipeline managed by Terraform."
}

variable "admin_group_id" {
  description = "Object ID of an Entra security group granted the Admin role on the deployment pipeline. Leave null to skip."
  type        = string
  default     = null
}

variable "stages" {
  description = <<-EOT
    Ordered array of deployment pipeline stages (between 2 and 10). Stage names are
    predefined here; the assigned workspace is resolved automatically from the
    corresponding environment's remote state via `source_environment`. Leave
    `source_environment` null for a stage that should have no workspace assigned.
  EOT
  type = list(object({
    display_name       = string
    description        = optional(string, "")
    is_public          = optional(bool, false)
    source_environment = optional(string)
  }))
  default = [
    {
      display_name       = "Development"
      description        = "Development stage."
      is_public          = false
      source_environment = "dev"
    },
    {
      display_name       = "Test"
      description        = "Test stage."
      is_public          = false
      source_environment = "nonprod"
    },
    {
      display_name       = "Production"
      description        = "Production stage."
      is_public          = true
      source_environment = "prod"
    }
  ]

  validation {
    condition = alltrue([
      for s in var.stages :
      s.source_environment == null || contains(["dev", "nonprod", "prod"], s.source_environment)
    ])
    error_message = "source_environment must be one of 'dev', 'nonprod', 'prod', or null."
  }
}

variable "active_environments" {
  description = <<-EOT
    Environments whose stages are (re)wired into the deployment pipeline on this run.
    The pipeline grows incrementally as environments come online: ["dev", "nonprod"]
    when Non-Prod is deployed, then ["dev", "nonprod", "prod"] when Prod is deployed.
    Only the remote state of listed environments is read; their stages are refreshed
    from that state. The pipeline is grow-only: any stage already present in the live
    pipeline is detected and preserved even when its environment is not listed here, so
    re-running an earlier stage (e.g. Non-Prod) never drops a later stage (e.g. Prod).
  EOT
  type        = list(string)
  default     = ["dev", "nonprod", "prod"]

  validation {
    condition = alltrue([
      for e in var.active_environments : contains(["dev", "nonprod", "prod"], e)
    ])
    error_message = "active_environments may only contain 'dev', 'nonprod', or 'prod'."
  }
}
