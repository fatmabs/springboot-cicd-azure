# data "azurerm_client_config" "current" {}




# resource "azurerm_key_vault" "this" {
#   name                        = "${var.environment}-${var.name_prefix}-kv-${random_id.randomness.hex}"
#   location                    = var.location
#   resource_group_name         = var.resource_group_name
#   tenant_id                    = data.azurerm_client_config.current.tenant_id
#   sku_name                    = var.sku_name
#   soft_delete_retention_days  = var.soft_delete_retention_days
#   purge_protection_enabled    = var.purge_protection_enabled
#   rbac_authorization_enabled = true
#   tags = merge({
#     Environment = var.environment
#     ManagedBy   = "Terraform"
#   }, var.tags)
  
# }