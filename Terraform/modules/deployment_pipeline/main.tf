resource "fabric_deployment_pipeline" "this" {
  display_name = var.display_name
  description  = var.description

  stages = [
    for stage in var.stages : {
      display_name = stage.display_name
      description  = stage.description
      is_public    = stage.is_public
      workspace_id = stage.workspace_id
    }
  ]
}

# Grant an Entra security group the Admin role on the deployment pipeline.
resource "fabric_deployment_pipeline_role_assignment" "admin_group" {
  count = var.admin_group_id == null ? 0 : 1

  deployment_pipeline_id = fabric_deployment_pipeline.this.id
  role                   = "Admin"

  principal = {
    id   = var.admin_group_id
    type = "Group"
  }
}
