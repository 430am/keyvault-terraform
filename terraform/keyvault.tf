data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
    name                        = "kv${random_pet.naming.id}"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name
    sku_name                    = "standard"
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days  = 7
    purge_protection_enabled = false

    enabled_for_deployment = true
    rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "kv_admin" {
    scope = azurerm_key_vault.kv.id
    role_definition_name = "Key Vault Administrator"
    principal_id = data.azurerm_client_config.current.object_id

    depends_on = [ azurerm_key_vault.kv ]
}

resource "azurerm_key_vault_secret" "private_key" {
    name         = "ssh-${random_pet.naming.id}-private-key"
    value_wo        = ephemeral.tls_private_key.ssh-vm-priv.private_key_pem
    value_wo_version = "1"
    key_vault_id = azurerm_key_vault.kv.id

    depends_on = [ azurerm_role_assignment.kv_admin ]
}

resource "azurerm_key_vault_secret" "public_key" {
    key_vault_id = azurerm_key_vault.kv.id
    name = "ssh-${random_pet.naming.id}-public-key"
    value = ephemeral.tls_public_key.ssh-vm-pub.public_key_pem
    value_wo_version = "1"

    depends_on = [ azurerm_role_assignment.kv_admin ]
}