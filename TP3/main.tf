# main.tf

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Resource Group
resource "azurerm_resource_group" "myRessourceGroup" {
  name     = var.resource_group_name
  location = var.location
}

# VM 1
resource "azurerm_linux_virtual_machine" "myLinuxVirtualMachine_1" {
  name                = "az-ciikorrr-frontend"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.myNic_frontend.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "vm1-os-disk"
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

  custom_data = base64encode(file("${path.module}/cloud-init/vm1.yaml"))
}

# VM 2
resource "azurerm_linux_virtual_machine" "myLinuxVirtualMachine_2" {
  name                = "az-ciikorrr-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.myNic_backend.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "vm2-os-disk"
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

  custom_data = base64encode(file("${path.module}/cloud-init/vm2.yaml"))
}

data "azurerm_client_config" "current" {}