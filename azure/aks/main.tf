########################### Providers ##########################

terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = ">= 3.73.0"
  }
}

provider "azurerm" {
  features {}
}