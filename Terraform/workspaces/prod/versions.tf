terraform {
  required_version = ">= 1.5.0"

  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = ">= 1.11.0"
    }
  }

  # Remote state. Backend settings are supplied at init time via -backend-config.
  # use_azuread_auth makes the backend authenticate to the state storage account with the
  # caller's Entra ID identity (RBAC: Storage Blob Data Contributor) instead of account keys,
  # which are blocked by policy (listKeys is denied).
  backend "azurerm" {
    use_azuread_auth = true
  }
}
