# main.tf

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "myRessourceGroup" {
  name     = var.resource_group_name
  location = var.location
}



resource "azurerm_linux_virtual_machine" "myLinuxVirtualMachine" {
  name                = "terraform-ciikorrr"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.myNetworkInterface.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "vm-os-disk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

    identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}