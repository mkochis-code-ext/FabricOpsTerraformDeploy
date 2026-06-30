output "id" {
  description = "The Workspace ID."
  value       = fabric_workspace.this.id
}

output "display_name" {
  description = "The Workspace display name."
  value       = fabric_workspace.this.display_name
}

output "capacity_id" {
  description = "The capacity assigned to the Workspace."
  value       = fabric_workspace.this.capacity_id
}
