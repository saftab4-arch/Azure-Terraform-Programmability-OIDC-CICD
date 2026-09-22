terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "syedtfstate2026"
    container_name       = "tfstate"
    key                  = "lab4/terraform.tfstate"

  }

}

