# Creation du Vnet

resource "azurerm_virtual_network" "myVNet" {
  name                = "vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Création du subnet

resource "azurerm_subnet" "mySubnet" {
  name                 = "vm-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.myVNet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Création de l'interface reseau pour la VM exposée

resource "azurerm_network_interface" "myNic_frontend" {
  name                = "vm-nic-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.myFront_Public_IP.id
    private_ip_address            = "10.0.1.5"
  }
}

# Création de l'interface reseau pour la VM bastion

resource "azurerm_network_interface" "myNic_backend" {
  name                = "vm-nic-2"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }
}

# Creation du NSG

resource "azurerm_network_security_group" "myVM_NSG" {
    name    =   "vm-nsg"
    resource_group_name = azurerm_resource_group.myRessourceGroup.name
    location = azurerm_resource_group.myRessourceGroup.location
}

# Rule pour accès SSH vers frontend

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.myVM_NSG.name
  resource_group_name         = azurerm_resource_group.myRessourceGroup.name
}

# Rule pour avoir accès au netdata

resource "azurerm_network_security_rule" "allow_netdata" {
  name                        = "Allow-netdata"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "19999"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.myVM_NSG.name
  resource_group_name         = azurerm_resource_group.myRessourceGroup.name
}

# Rule pour HTTP internet vers frontend

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.myVM_NSG.name
  resource_group_name         = azurerm_resource_group.myRessourceGroup.name
}

# Rule pour HTTP internet vers frontend

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "Allow-HTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.myVM_NSG.name
  resource_group_name         = azurerm_resource_group.myRessourceGroup.name
}

# Rule pour le trafic entre front & back

resource "azurerm_network_security_rule" "allow_vnet" {
  name                        = "Allow-VNet"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  network_security_group_name = azurerm_network_security_group.myVM_NSG.name
  resource_group_name         = azurerm_resource_group.myRessourceGroup.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
  subnet_id                 = azurerm_subnet.mySubnet.id
  network_security_group_id = azurerm_network_security_group.myVM_NSG.id
}

resource "azurerm_public_ip" "myFront_Public_IP" {
  name                = "vm-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.domaine_name
}