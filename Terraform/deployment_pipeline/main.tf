locals {
  # Keep only the stages whose source environment is currently active. Stages are
  # added as environments come online (dev+nonprod, then dev+nonprod+prod).
  active_stages = [
    for s in var.stages : s
    if s.source_environment != null && contains(var.active_environments, s.source_environment)
  ]

  # Resolve each referenced environment to its workspace ID from remote state.
  workspace_ids = {
    for env, state in data.terraform_remote_state.env : env => state.outputs.workspace_id
  }

  # Map the active stages onto the resolved workspace IDs.
  resolved_stages = [
    for s in local.active_stages : {
      display_name = s.display_name
      description  = s.description
      is_public    = s.is_public
      workspace_id = local.workspace_ids[s.source_environment]
    }
  ]
}

module "deployment_pipeline" {
  source = "../modules/deployment_pipeline"

  display_name = var.deployment_pipeline_display_name
  description  = var.deployment_pipeline_description
  stages       = local.resolved_stages
}
