output "id" {
  description = "The Deployment Pipeline ID."
  value       = fabric_deployment_pipeline.this.id
}

output "display_name" {
  description = "The Deployment Pipeline display name."
  value       = fabric_deployment_pipeline.this.display_name
}

output "stages" {
  description = "The resolved Deployment Pipeline stages, including generated stage IDs."
  value       = fabric_deployment_pipeline.this.stages
}
