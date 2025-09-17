# Backend configuration for remote state storage
# Uncomment and configure when ready to use remote state

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "terraformstate12345"  # Must be globally unique
#     container_name       = "tfstate"
#     key                  = "terraform.tfstate"
#   }
# }

# Alternative: Use local backend for development
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }
