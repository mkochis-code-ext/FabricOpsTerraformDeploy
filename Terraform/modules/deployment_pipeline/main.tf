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
