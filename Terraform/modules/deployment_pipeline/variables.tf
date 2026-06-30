variable "display_name" {
  description = "The Deployment Pipeline display name. At most 246 characters."
  type        = string
}

variable "description" {
  description = "The Deployment Pipeline description."
  type        = string
  default     = ""
}

variable "stages" {
  description = "The ordered collection of Deployment Pipeline stages. Must contain between 2 and 10 stages."
  type = list(object({
    display_name = string
    description  = optional(string, "")
    is_public    = optional(bool, false)
    workspace_id = optional(string)
  }))

  validation {
    condition     = length(var.stages) >= 2 && length(var.stages) <= 10
    error_message = "A deployment pipeline must contain between 2 and 10 stages."
  }
}

variable "admin_group_id" {
  description = "Object ID of an Entra security group to grant the Admin role on the Deployment Pipeline. Leave null to skip the assignment."
  type        = string
  default     = null
}
