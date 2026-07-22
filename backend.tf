terraform {
  backend "azurerm" {
    resource_group_name  = "rg-2tier-wizexercise"
    storage_account_name = "st2tiermongobkpjhe3h7"
    container_name       = "tfstate"
    key                  = "2tierwebappexecise.tfstate"
  }
}
