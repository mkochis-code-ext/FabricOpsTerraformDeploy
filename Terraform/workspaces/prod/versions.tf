terraform {
  required_version = ">= 1.5.0"

  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = ">= 1.11.0"
    }
  }

  # Remote state. Backend settings are supplied at init time via -backend-config.
  backend "azurerm" {}
}
