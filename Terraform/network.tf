resource "azurerm_virtual_network" "myVirtualNetwork" {
  name                = "vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "mySubnet" {
  name                 = "vm-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.myVirtualNetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "myNetworkInterface" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myPublicIP.id
  }
}

resource "azurerm_public_ip" "myPublicIP" {
  name                = "vm-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "myvm123"
}

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
        source_address_prefix = var.public_IP
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.myNetworkInterface.id
  network_security_group_id = azurerm_network_security_group.myVMNsg.id
}