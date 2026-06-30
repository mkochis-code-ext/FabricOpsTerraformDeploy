provider "fabric" {
  tenant_id = var.tenant_id
  client_id = var.client_id

  # When running in Azure DevOps with Workload Identity Federation, set use_oidc = true.
  # The client secret (if used) is read from the FABRIC_CLIENT_SECRET environment variable.
  use_oidc = var.use_oidc
}
