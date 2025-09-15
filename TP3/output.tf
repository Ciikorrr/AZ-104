output "MyVmPublicIPAddress" {
    description = "My public IP Address"
    value = azurerm_public_ip.myFront_Public_IP.ip_address
}

output "MyPublicDNS" {
    description = "My public DNS"
    value = azurerm_public_ip.myFront_Public_IP.fqdn
}