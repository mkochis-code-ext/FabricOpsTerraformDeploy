output "deployment_pipeline_id" {
  description = "The Fabric deployment pipeline ID."
  value       = module.deployment_pipeline.id
}

output "deployment_pipeline_stages" {
  description = "The deployment pipeline stages, including generated stage IDs."
  value       = module.deployment_pipeline.stages
}
