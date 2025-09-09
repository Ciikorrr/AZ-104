output "MyVmPublicIPAddress" {
    description = "My public IP Address"
    value = azurerm_public_ip.myPublicIP.ip_address
}

output "MyPublicDNS" {
    description = "My public DNS"
    value = azurerm_public_ip.myPublicIP.fqdn
}