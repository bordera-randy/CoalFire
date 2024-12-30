terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
    }
  }

}

provider "azurerm" {
  subscription_id            = "a1c4dba0-b0eb-4923-8c56-061b0d014d56"
  skip_provider_registration = true
  features {}
}