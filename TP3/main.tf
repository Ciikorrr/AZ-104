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

  custom_data = base64encode(<<EOF
#cloud-config
users:
  - name: ciikorrr
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh-authorized-keys:
      - ${file("./ssh_keys/az_tp3.pub")}
package_update: true
packages:
  - nginx
write_files:
  - path: /etc/nginx/sites-available/default
    content: |
      server {
          listen 80;
          location / {
              proxy_pass http://${azurerm_network_interface.myNic_backend.private_ip_address};
              proxy_set_header Host \$host;
              proxy_set_header X-Real-IP \$remote_addr;
          }
      }
runcmd:
  - systemctl enable nginx
  - systemctl restart nginx
EOF
)
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

  custom_data = base64encode(<<EOF
#cloud-config
package_update: true
packages:
  - nginx
write_files:
  - path: /var/www/html/index.html
    content: |
      <html><body><h1>Hello depuis le backend !</h1></body></html>
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
EOF
)
}

data "azurerm_client_config" "current" {}