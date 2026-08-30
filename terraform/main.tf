resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_container_registry" "this" {
  name                     = "myprojectacr123"
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  sku                      = "Basic"
  admin_enabled            = false
  tags                     = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

