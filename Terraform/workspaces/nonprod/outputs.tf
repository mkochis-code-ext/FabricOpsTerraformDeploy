output "workspace_id" {
  description = "The Non-Prod Fabric workspace ID."
  value       = module.workspace.id
}

output "workspace_display_name" {
  description = "The Non-Prod Fabric workspace display name."
  value       = module.workspace.display_name
}
