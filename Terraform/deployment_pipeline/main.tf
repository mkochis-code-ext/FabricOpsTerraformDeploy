# Look up any deployment pipelines that already exist in the tenant. The list
# data source returns an empty set (rather than erroring) when none exist, so it
# is safe to evaluate on the very first run before the pipeline is created.
data "fabric_deployment_pipelines" "all" {}

# Read the full definition (including stages and their workspace assignments) of the
# existing pipeline that matches our display name, when one is present. Gated by count
# so the singular data source - which errors when nothing matches - is only evaluated
# once we know the pipeline exists.
data "fabric_deployment_pipeline" "existing" {
  count = local.existing_pipeline_id == null ? 0 : 1

  id = local.existing_pipeline_id
}

locals {
  # ID of the already-deployed pipeline with our display name, or null on the first run.
  existing_pipeline_id = one([
    for p in data.fabric_deployment_pipelines.all.values : p.id
    if p.display_name == var.deployment_pipeline_display_name
  ])

  # Map of stage display name -> source environment, taken from the stage definitions.
  # Used to translate the live pipeline's stages back into environment names.
  stage_environment_by_name = {
    for s in var.stages : s.display_name => s.source_environment
    if s.source_environment != null
  }

  # Stages currently wired into the live pipeline (empty on the first run).
  existing_stages = length(data.fabric_deployment_pipeline.existing) > 0 ? data.fabric_deployment_pipeline.existing[0].stages : []

  # Existing stage workspace assignment keyed by environment. Lets us re-use the live
  # assignment for stages that are already deployed but are not part of this run's
  # active_environments (e.g. keep Production wired when Non-Prod re-deploys).
  existing_workspace_by_environment = {
    for st in local.existing_stages :
    local.stage_environment_by_name[st.display_name] => st.workspace_id
    if lookup(local.stage_environment_by_name, st.display_name, null) != null && st.workspace_id != null
  }

  # Environments already represented by a workspace-assigned stage in the live pipeline.
  existing_environments = keys(local.existing_workspace_by_environment)

  # Grow-only environment set: everything requested for this run plus everything already
  # wired into the live pipeline. Prevents a re-run of an earlier stage (Non-Prod) from
  # shrinking the pipeline and dropping a later stage (Prod) that is already in place.
  effective_environments = distinct(concat(var.active_environments, local.existing_environments))

  # Resolve each active environment to its workspace ID from remote state. Only active
  # environments are read from remote state; grow-only environments reuse the live
  # pipeline's existing workspace assignment.
  workspace_ids = {
    for env, state in data.terraform_remote_state.env : env => state.outputs.workspace_id
  }

  # Build the ordered stage list (stage order follows var.stages: dev -> nonprod -> prod).
  # A stage is included when its environment is active this run or already deployed; its
  # workspace comes from fresh remote state when active, otherwise from the live pipeline.
  resolved_stages = [
    for s in var.stages : {
      display_name = s.display_name
      description  = s.description
      is_public    = s.is_public
      workspace_id = contains(var.active_environments, s.source_environment) ? local.workspace_ids[s.source_environment] : lookup(local.existing_workspace_by_environment, s.source_environment, null)
    }
    if s.source_environment != null && contains(local.effective_environments, s.source_environment)
  ]
}

module "deployment_pipeline" {
  source = "../modules/deployment_pipeline"

  display_name   = var.deployment_pipeline_display_name
  description    = var.deployment_pipeline_description
  stages         = local.resolved_stages
  admin_group_id = var.admin_group_id
}
