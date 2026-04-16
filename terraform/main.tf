data "azurerm_key_vault" "secret_store" {
    name = azurerm_key_vault.kv.name
    resource_group_name = azurerm_key_vault.kv.resource_group_name
}

data "azurerm_key_vault_secret" "vm_public_key" {
    key_vault_id = data.azurerm_key_vault.secret_store.id
    name = azurerm_key_vault_secret.public_key.name    
}

resource "random_pet" "naming" {
    separator = ""
    length    = 2
}

resource "azurerm_resource_group" "rg" {
    name     = "${random_pet.naming.id}-rg"
    location = var.location
}

resource "azurerm_virtual_network" "vnet" {
    location = azurerm_resource_group.rg.location
    name = "vnet-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
    name                 = "subnet-${random_pet.naming.id}"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion-sub" {
    name = "AzureBastionSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip-bastion" {
    allocation_method = "Static"
    location = var.location
    name = "pip-bastion-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"

}

resource "azurerm_bastion_host" "bastion" {
    name                = "bastion-${random_pet.naming.id}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    tunneling_enabled = true
    sku = "Standard"

    ip_configuration {
        name                 = "bastion-ip-config"
        subnet_id            = azurerm_subnet.bastion-sub.id
        public_ip_address_id = azurerm_public_ip.pip-bastion.id
    }
}

resource "azurerm_network_interface" "vm-nic" {
    location = var.location
    name = "vm-nic-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "ip-config-${random_pet.naming.id}"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.subnet.id
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    location = var.location
    name = "vm-${random_pet.naming.id}"
    network_interface_ids = [ azurerm_network_interface.vm-nic.id ]
    resource_group_name = azurerm_resource_group.rg.name
    size = "Standard_DS1_v2"

    os_disk {
        name = "osdisk-${random_pet.naming.id}"
        caching = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "24.04-LTS"
        version   = "latest"
    }

    admin_username = "ladmin"

    admin_ssh_key {
      username = "ladmin"
      public_key = data.azurerm_key_vault_secret.vm_public_key.value
    }
}