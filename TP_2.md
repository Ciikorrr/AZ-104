# TP 2 Azure

## Network Security Group

###  Ajouter un NSG à votre déploiement Terraform

```
resource "azurerm_network_security_group" "vm_nsg" {
    name    =   "vm-nsg"
    resource_group_name = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location

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
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}
```

### Prouver que ça fonctionne, rendu attendu

```bash
└─$ az vm show \                                                            
  --resource-group dfg \
  --name Terraform-ciikorrr \
  --show-details \
  -o json
```

```bash
└─$ az network nsg list --resource-group dfg -o json
```
## Un ptit nom DNS

### Ajouter un ouput custom à `terraform apply`

#### CF : output.tf

### Proooofs ! 

#### L'output custom

```bash
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m10s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m20s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m30s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m40s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Creation complete after 49s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/myRessourceGroup/providers/Microsoft.Compute/virtualMachines/terraform-ciikorrr]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

MyPublicDNS = "myvm123.uksouth.cloudapp.azure.com"
MyVmPublicIPAddress = "172.167.20.37"
```

#### La connection ssh

```bash
└─$ ssh ciikorrr@myvm123.uksouth.cloudapp.azure.com
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.11.0-1018-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Sep  9 19:50:55 UTC 2025

  System load:  0.04              Processes:             111
  Usage of /:   5.7% of 28.02GB   Users logged in:       0
  Memory usage: 29%               IPv4 address for eth0: 10.0.1.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

Last login: Tue Sep  9 19:49:32 2025 from 90.47.59.94
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ciikorrr@terraform-ciikorrr:~$ 
```

## Blob Storage



