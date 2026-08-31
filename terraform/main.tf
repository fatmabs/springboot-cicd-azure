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


resource "azurerm_service_plan" "app" {
  name                = "my-project-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = "India South Central"

  os_type  = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "my-project-webapp-123"
  resource_group_name = azurerm_resource_group.this.name
  location            = "India South Central"

  service_plan_id = azurerm_service_plan.app.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = false

    container_registry_use_managed_identity = true

    application_stack {
      docker_image_name   = "hello-api:latest"
      docker_registry_url = "https://${azurerm_container_registry.this.login_server}"
    }
  }
}

resource "azurerm_role_assignment" "webapp_acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}
