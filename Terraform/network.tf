resource "azurerm_network_security_group" "myVMNsg" {
    name    =   "vm-nsg"
    resource_group_name = azurerm_resource_group.myRessourceGroup.name
    location = azurerm_resource_group.myRessourceGroup.location

    security_rule {
        name = "AllowSSHconnectionFromMyIP"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "0.0.0.0/0"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.myNetworkInterface.id
  network_security_group_id = azurerm_network_security_group.myVMNsg.id
}