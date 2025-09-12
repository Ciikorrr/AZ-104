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

```json
└─$ az vm show   --resource-group MyRessourceGroup \ 
  --name terraform-ciikorrr \
  --query "networkProfile.networkInterfaces[].id" \
  -o tsv
/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Network/networkInterfaces/vm-nic
┌──(M.M㉿fedora)-[~/Efrei/CloudComputing/Terraform]
└─$ az network nic show --ids /subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Network/networkInterfaces/vm-nic -o json
{
  "auxiliaryMode": "None",
  "auxiliarySku": "None",
  "disableTcpStateTracking": false,
  "dnsSettings": {
    "appliedDnsServers": [],
    "dnsServers": [],
    "internalDomainNameSuffix": "vrufs1ekngne5le2cimbgljkzh.zx.internal.cloudapp.net"
  },
  "enableAcceleratedNetworking": false,
  "enableIPForwarding": false,
  "etag": "W/\"f96bcb6b-28ca-40a8-9195-a9c3267f1022\"",
  "hostedWorkloads": [],
  "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Network/networkInterfaces/vm-nic",
  "ipConfigurations": [
    {
      "etag": "W/\"f96bcb6b-28ca-40a8-9195-a9c3267f1022\"",
      "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Network/networkInterfaces/vm-nic/ipConfigurations/internal",
      "name": "internal",
      "primary": true,
      "privateIPAddress": "10.0.1.4",
      "privateIPAddressVersion": "IPv4",
      "privateIPAllocationMethod": "Dynamic",
      "provisioningState": "Succeeded",
      "publicIPAddress": {
        "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Network/publicIPAddresses/vm-ip",
        "resourceGroup": "myRessourceGroup"
      },
      "resourceGroup": "myRessourceGroup",
      "subnet": {
        "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Network/virtualNetworks/vm-vnet/subnets/vm-subnet",
        "resourceGroup": "myRessourceGroup"
      },
      "type": "Microsoft.Network/networkInterfaces/ipConfigurations"
    }
  ],
  "location": "uksouth",
  "macAddress": "00-0D-3A-7F-F4-74",
  "name": "vm-nic",
  "networkSecurityGroup": {
    "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Network/networkSecurityGroups/vm-nsg",
    "resourceGroup": "myRessourceGroup"
  },
  "nicType": "Standard",
  "primary": true,
  "provisioningState": "Succeeded",
  "resourceGroup": "myRessourceGroup",
  "resourceGuid": "db7046be-378c-4e16-9815-2cec4fb7ec97",
  "tags": {},
  "tapConfigurations": [],
  "type": "Microsoft.Network/networkInterfaces",
  "virtualMachine": {
    "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Compute/virtualMachines/terraform-ciikorrr",
    "resourceGroup": "myRessourceGroup"
  },
  "vnetEncryptionSupported": false
}
```
```bash
└─$ ssh ciikorrr@myvm123.uksouth.cloudapp.azure.com -i ~/.ssh/cloud_tp1
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1089-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Fri Sep 12 12:05:00 UTC 2025

  System load:  0.0               Processes:             111
  Usage of /:   6.1% of 28.89GB   Users logged in:       0
  Memory usage: 31%               IPv4 address for eth0: 10.0.1.4
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Infrastructure is not enabled.

0 updates can be applied immediately.

46 additional security updates can be applied with ESM Infra.
Learn more about enabling ESM Infra service for Ubuntu 20.04 at
https://ubuntu.com/20-04

New release '22.04.5 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


*** System restart required ***
Last login: Fri Sep 12 11:43:54 2025 from 77.193.71.182
ciikorrr@terraform-ciikorrr:~$ sudo vim /etc/ssh/sshd_config
ciikorrr@terraform-ciikorrr:~$ sudo systemctl restart sshd
ciikorrr@terraform-ciikorrr:~$ systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2025-09-12 12:06:24 UTC; 8s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 22558 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 22559 (sshd)
      Tasks: 1 (limit: 1063)
     Memory: 1.0M
     CGroup: /system.slice/ssh.service
             └─22559 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups

Sep 12 12:06:24 terraform-ciikorrr systemd[1]: Starting OpenBSD Secure Shell server...
Sep 12 12:06:24 terraform-ciikorrr sshd[22559]: Server listening on 0.0.0.0 port 2222.
Sep 12 12:06:24 terraform-ciikorrr sshd[22559]: Server listening on :: port 2222.
Sep 12 12:06:24 terraform-ciikorrr systemd[1]: Started OpenBSD Secure Shell server.
```
```bash
└─$ ssh ciikorrr@20.68.218.111 -i ~/.ssh/cloud_tp1 -p 2222
ssh: connect to host 20.68.218.111 port 2222: Connection timed out
```

## Un ptit nom DNS

### Ajouter un ouput custom à `terraform apply`

#### output.tf

### Proooofs ! 

#### L'output custom

```bash
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m10s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m20s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m30s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Still creating... [00m40s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine: Creation complete after 49s [id=/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/myRessourceGroup/providers/Microsoft.Compute/virtualMachines/terraform-ciikorrr]

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

### Let's go

#### Compléter votre plan Terraform pour déployer du Blob Storage pour votre VM

storage.tf

### Proooooooofs

#### Prouvez que tout est bien configuré, depuis la VM Azure

#### Installation de azcopy

```bash
ciikorrr@terraform-ciikorrr:~$ curl -sSL -O https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
ciikorrr@terraform-ciikorrr:~$ sudo dpkg -i packages-microsoft-prod.deb
Selecting previously unselected package packages-microsoft-prod.
(Reading database ... 59172 files and directories currently installed.)
Preparing to unpack packages-microsoft-prod.deb ...
Unpacking packages-microsoft-prod (1.0-ubuntu20.04.1) ...
Setting up packages-microsoft-prod (1.0-ubuntu20.04.1) ...
ciikorrr@terraform-ciikorrr:~$ sudo apt update
Hit:1 http://azure.archive.ubuntu.com/ubuntu focal InRelease
Get:2 http://azure.archive.ubuntu.com/ubuntu focal-updates InRelease [128 kB] 
Get:3 http://azure.archive.ubuntu.com/ubuntu focal-backports InRelease [128 kB]
...
ciikorrr@terraform-ciikorrr:~$ sudo apt install azcopy
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  azcopy
0 upgraded, 1 newly installed, 0 to remove and 41 not upgraded.
Need to get 23.0 MB of archives.
After this operation, 56.5 MB of additional disk space will be used.
Get:1 https://packages.microsoft.com/ubuntu/20.04/prod focal/main amd64 azcopy amd64 10.30.1 [23.0 MB]
Fetched 23.0 MB in 1s (24.2 MB/s) 
Selecting previously unselected package azcopy.
(Reading database ... 59180 files and directories currently installed.)
Preparing to unpack .../azcopy_10.30.1_amd64.deb ...
Unpacking azcopy (10.30.1) ...
Setting up azcopy (10.30.1) ...
ciikorrr@terraform-ciikorrr:~$ azcopy --version
azcopy version 10.30.1
```

#### Connexion avec azcopy

```bash
ciikorrr@terraform-ciikorrr:~$ azcopy login --identity
INFO: Login with identity succeeded.
```

#### Création du fichier de test

```bash
ciikorrr@terraform-ciikorrr:~$ echo "hello world !" > myfile.txt
```

#### Upload du fichier dans le blob storage

```bash
ciikorrr@terraform-ciikorrr:~$ azcopy copy "/home/ciikorrr/myfile.txt" "https://mystorageaccount1a2b3c.blob.core.windows.net/myfirstcontainer" --recursive=false
INFO: Scanning...
INFO: Autologin not specified.
INFO: Authenticating to destination using Azure AD
INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

Job 8e043710-4069-f340-4964-2d0de8c0e2c8 has started
Log file is located at: /home/ciikorrr/.azcopy/8e043710-4069-f340-4964-2d0de8c0e2c8.log

100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total, 2-sec Throughput (Mb/s): 0.0001


Job 8e043710-4069-f340-4964-2d0de8c0e2c8 summary
Elapsed Time (Minutes): 0.0334
Number of File Transfers: 1
Number of Folder Property Transfers: 0
Number of Symlink Transfers: 0
Total Number of Transfers: 1
Number of File Transfers Completed: 1
Number of Folder Transfers Completed: 0
Number of File Transfers Failed: 0
Number of Folder Transfers Failed: 0
Number of File Transfers Skipped: 0
Number of Folder Transfers Skipped: 0
Number of Symbolic Links Skipped: 0
Number of Hardlinks Converted: 0
Number of Special Files Skipped: 0
Total Number of Bytes Transferred: 14
Final Job Status: Completed
```

#### Download du fichier depuis le blob storage

```bash
ciikorrr@terraform-ciikorrr:/tmp$ azcopy copy "https://mystorageaccount1a2b3c.blob.core.windows.net/myfirstcontainer/myfile.txt" "./myfiledownloaded.txt"
INFO: Scanning...
INFO: Autologin not specified.
INFO: Authenticating to source using Azure AD
INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

Job 30768f39-b7dd-c541-5387-1c39627af518 has started
Log file is located at: /home/ciikorrr/.azcopy/30768f39-b7dd-c541-5387-1c39627af518.log

100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total, 2-sec Throughput (Mb/s): 0.0001


Job 30768f39-b7dd-c541-5387-1c39627af518 summary
Elapsed Time (Minutes): 0.0334
Number of File Transfers: 1
Number of Folder Property Transfers: 0
Number of Symlink Transfers: 0
Total Number of Transfers: 1
Number of File Transfers Completed: 1
Number of Folder Transfers Completed: 0
Number of File Transfers Failed: 0
Number of Folder Transfers Failed: 0
Number of File Transfers Skipped: 0
Number of Folder Transfers Skipped: 0
Number of Symbolic Links Skipped: 0
Number of Hardlinks Converted: 0
Number of Special Files Skipped: 0
Total Number of Bytes Transferred: 14
Final Job Status: Completed
ciikorrr@terraform-ciikorrr:/tmp$ cat myfiledownloaded.txt 
hello world !
```

### Déterminez comment azcopy login --identity vous a authentifié

Lorsque la commande azcopy login --identity est executé, cela itulise l'identité managée de la machine virtuelle. La VM possède un endpoint IMDS (Instance Metadata Service) accessible uniquement en local `http://169.254.169.254/metadata/identity/oauth2/token`. Azcopy envoi une requête à ce endpoint afin d'avoir un JWT signé par Azure AD, Azure Storage verifie ce JWT et autorise l'accès, en fonction du rôle assigné, dans ce cas là c'est `Storage Blob Data Contributor`

####  Requêtez un JWT d'authentification auprès du service que vous venez d'identifier, manuellement

```bash
ciikorrr@terraform-ciikorrr:/tmp$ curl -s -H "Metadata:true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/"
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkpZaEFjVFBNWl9MWDZEQmxPV1E3SG4wTmVYRSIsImtpZCI6IkpZaEFjVFBNWl9MWDZEQmxPV1E3SG4wTmVYRSJ9.eyJhdWQiOiJodHRwczovL3N0b3JhZ2UuYXp1cmUuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzQxMzYwMGNmLWJkNGUtNGM3Yy04YTYxLTY5ZTczY2RkZjczMS8iLCJpYXQiOjE3NTc2NjEzNjAsIm5iZiI6MTc1NzY2MTM2MCwiZXhwIjoxNzU3NzQ4MDYwLCJhaW8iOiJrMlJnWU5oOW5kWHZjTmtWK3c1cC9aTWREb0sxQUE9PSIsImFwcGlkIjoiNjBiZjMzY2YtZTg5YS00MTNjLTg2NTctMzA3OGRlOGQ3M2E2IiwiYXBwaWRhY3IiOiIyIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNDEzNjAwY2YtYmQ0ZS00YzdjLThhNjEtNjllNzNjZGRmNzMxLyIsImlkdHlwIjoiYXBwIiwib2lkIjoiNDg4OGJjMDMtYzQ2NS00MWE0LTkwZjUtMmI1ZmFjYTY4NzAwIiwicmgiOiIxLkFUc0F6d0EyUVU2OWZFeUtZV25uUE4zM01ZR21CdVRVODZoQ2tMYkNzQ2xKZXZFVkFRQTdBQS4iLCJzdWIiOiI0ODg4YmMwMy1jNDY1LTQxYTQtOTBmNS0yYjVmYWNhNjg3MDAiLCJ0aWQiOiI0MTM2MDBjZi1iZDRlLTRjN2MtOGE2MS02OWU3M2NkZGY3MzEiLCJ1dGkiOiIyMmp3RGtsSDIwcTNFa0lUanIxR0FBIiwidmVyIjoiMS4wIiwieG1zX2Z0ZCI6IjJyV2diRDdvZVloNlNRMUNDbm9tbXNaLXNickVhUjgwanN6SHM5SUZCeUVCZFd0emIzVjBhQzFrYzIxeiIsInhtc19pZHJlbCI6IjggNyIsInhtc19taXJpZCI6Ii9zdWJzY3JpcHRpb25zL2I0NWI0Y2JlLWE4OTEtNGFhZi1hNTBlLTc0ZjA3ZGFhMTRiMC9yZXNvdXJjZWdyb3Vwcy9teVJlc3NvdXJjZUdyb3VwL3Byb3ZpZGVycy9NaWNyb3NvZnQuQ29tcHV0ZS92aXJ0dWFsTWFjaGluZXMvdGVycmFmb3JtLWNpaWtvcnJyIiwieG1zX3JkIjoiMC40MkxsWUJKaXRCWVM0ZUFVRWxEcDliVmJ1ZTIyNzZRdjZib3ltazE2UUZFT0lZSEdaV3hQcm54ZTRUUmgyNkVObXA1Vkh3RSIsInhtc190ZGJyIjoiRVUifQ.kar8Y6HFl_9cflfJDTXtfUipnDclejgUadneSBtYfGlqUdk-zCin2oTR_mxhfuESK7nNaJxgqQn3xi3DV5pxoejRb9U9uE5D1wgvGqBa6oGOWSAX3wMzGD7uBQTtjusxwgP_qXa14KPkygyB7gNzXLAdcEYgoVeLv6enAUAslb8EHydn5Xhl0TsKN_aDbiwMeagU-SV-vWj5vvZv0v14RgNN189y_YBPCZPAbGOCzAwiWHNUdwn_u_Rex7LJBIMqhr9LdcipLvmAoub7ILQSsJF7p_rMkQcwfb6wYgb_2Te8MY2jHeOZBEs3mwKAlPkeNDMm7-MEWp3ACo2qCH-OHA
```

#### Expliquez comment l'IP 169.254.169.254 peut être joignable

```bash
ciikorrr@terraform-ciikorrr:/tmp$ ip r
default via 10.0.1.1 dev eth0 proto dhcp src 10.0.1.4 metric 100 
10.0.1.0/24 dev eth0 proto kernel scope link src 10.0.1.4 metric 100 
168.63.129.16 via 10.0.1.1 dev eth0 proto dhcp src 10.0.1.4 metric 100 
169.254.169.254 via 10.0.1.1 dev eth0 proto dhcp src 10.0.1.4 metric 100
```
L’adresse 169.254.169.254 est une IP réservée au service de métadonnées dans Azure. Elle appartient à la plage link-local (169.254.0.0/16) et n’est pas routée sur Internet. Lorsqu’une VM en Azure envoie une requête vers cette adresse, l’hyperviseur intercepte le trafic et le redirige vers le Metadata Service d’Azure. Cela permet à la VM d’obtenir des informations sur sa configuration (ID, région, réseau, tags) ou encore des tokens d’identité managée, sans passer par Internet.

## Monitoring

### Une alerte CPU

#### Compléter votre plan Terraform et mettez en place une alerte CPU

monitoring.tf

### Une alerte mémoire

#### Compléter votre plan Terraform et mettez en place une alerte mémoire

### Proofs

#### Voir les alertes avec `az`

monitoring.tf

```bash
└─$ az monitor metrics alert list --resource-group MyRessourceGroup -o table
AutoMitigate    Description                                   Enabled    EvaluationFrequency    Location    Name                          ResourceGroup     Severity    TargetResourceRegion    TargetResourceType    WindowSize
--------------  --------------------------------------------  ---------  ---------------------  ----------  ----------------------------  ----------------  ----------  ----------------------  --------------------  ------------
True            Alert when CPU usage exceeds 70%              True       PT1M                   global      cpu-alert-terraform-ciikorrr  myRessourceGroup  2                                                         PT5M
True            Alert when Memory available is less the 512M  True       PT1M                   global      RAM-alert-terraform-ciikorrr  myRessourceGroup  2                                                         PT5M
```

#### Stress pour fire les alertes

```bash
ciikorrr@terraform-ciikorrr:~$ sudo apt update
...
ciikorrr@terraform-ciikorrr:~$ sudo apt install stress-ng
...
ciikorrr@terraform-ciikorrr:~$ stress-ng --cpu 4 --timeout 300s
stress-ng: info:  [15627] dispatching hogs: 4 cpu
stress-ng: info:  [15627] successful run completed in 300.42s (5 mins, 0.42 secs)
ciikorrr@terraform-ciikorrr:~$ stress-ng --vm 2 --vm-bytes 512M --timeout 300s
stress-ng: info:  [15679] dispatching hogs: 2 vm
stress-ng: info:  [15679] successful run completed in 300.01s (5 mins, 0.01 secs)
```

#### Vérifier que des alertes ont été fired

```bash
└─$ az monitor activity-log list -g MyRessourceGroup --offset 1h --query "[?category.value=='Administrative' && contains(operationName.value, 'alert')].{Time:eventTimestamp, AlertName:operationName.value, Status:status.value}" -o table
Time                          AlertName                              Status
----------------------------  -------------------------------------  ---------
2025-09-12T08:53:26.5654658Z  Microsoft.Insights/metricalerts/write  Succeeded
2025-09-12T08:41:02.2717354Z  Microsoft.Insights/metricalerts/write  Succeeded
```

## Vault

## Do it !

#### Compléter votre plan Terraform et mettez en place une Azure Key Vault

keyvault.tf

#### Avec une commande `az`, afficher le secret

```json
└─$ az keyvault secret show --name ciikorrrSecret --vault-name CiikorrrVaultKey
{
  "attributes": {
    "created": "2025-09-12T11:37:57+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoverableDays": 7,
    "recoveryLevel": "CustomizedRecoverable+Purgeable",
    "updated": "2025-09-12T11:37:57+00:00"
  },
  "contentType": "",
  "id": "https://ciikorrrvaultkey.vault.azure.net/secrets/CiikorrrSecret/1e31c8cf091f454a8eadb9d7b7c9888b",
  "kid": null,
  "managed": null,
  "name": "CiikorrrSecret",
  "tags": {},
  "value": "DdUdNQ&E^G*vIzeS"
}
```

#### Depuis la VM, afficher le secret

```bash
ciikorrr@terraform-ciikorrr:~$ vim scrapingsecret.sh
ciikorrr@terraform-ciikorrr:~$ chmod +x scrapingsecret.sh;
ciikorrr@terraform-ciikorrr:~$ ./scrapingsecret.sh
```

scrapingsecret.sh :
```bash
#!/bin/bash

KEYVAULT_NAME="CiikorrrVaultKey"
SECRET_NAME="ciikorrrSecret"

TOKEN=$(curl -s -H "Metadata:true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2021-01-01&resource=https://vault.azure.net" \
  | jq -r '.access_token')

SECRET_VALUE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://$KEYVAULT_NAME.vault.azure.net/secrets/$SECRET_NAME?api-version=7.3" \
  | jq -r '.value')

echo "La valeur du secret est : $SECRET_VALUE"
```