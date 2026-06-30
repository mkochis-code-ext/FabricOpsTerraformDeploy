output "workspace_id" {
  description = "The Dev Fabric workspace ID."
  value       = module.workspace.id
}

output "workspace_display_name" {
  description = "The Dev Fabric workspace display name."
  value       = module.workspace.display_name
}

output "git_connection_state" {
  description = "The Git connection state of the Dev workspace."
  value       = var.enable_git_integration ? fabric_workspace_git.this[0].git_connection_state : null
}
