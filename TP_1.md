# TP 1 Azure

## 1 Prerequis Azure Web

### Choix de l'algorithme de chiffrement

    Ne pas utiliser RSA
    source : https://www.sjoerdlangkemper.nl/2019/06/19/attacking-rsa/

    Utiliser un autre algorithme tel que ECDSA ou ED25519
    source : https://docs.callgoose.com/general/ed25519_vs_other_keys_for_ssh

### Génération de votre paire de clés

```bash
└─$ cd ~/.ssh
└─$ ssh-keygen -t ed25519 -f cloud_tp1
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in cloud_tp1
Your public key has been saved in cloud_tp1.pub
The key fingerprint is:
SHA256:6Wxmsw7h9cCL3j5ha0R2ToOMB3e8PJqcihoRWaa+Fo8 M.M@fedora
The key's randomart image is:
+--[ED25519 256]--+
|    o    .       |
|   =  . . o      |
|  +    = + .     |
| . .  ..*.B      |
|  +   .=SB o     |
|   * . *O+.      |
|  E ..++Oo.      |
| . ....*+o       |
|  ..  .+=.       |
+----[SHA256]-----+
```

### Configurer un agent SSH sur votre poste

```bash
eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/cloud_tp1
Enter passphrase for cloud_tp1:
Identity added: cloud_tp1 (M.M@fedora)
ssh-add -l
256 SHA256:6Wxmsw7h9cCL3j5ha0R2ToOMB3e8PJqcihoRWaa+Fo8 M.M@fedora (ED25519)
```

## 2 Prerequis AZ CLi

### Connectez-vous en SSH à la VM pour preuve

```bash
└─$ ssh azureuser@20.117.208.30
The authenticity of host '20.117.208.30 (20.117.208.30)' can't be established.
ED25519 key fingerprint is SHA256:Tz2QVeztw2QB32DIba5/Jyp+rmVPwxsuyJqj4cqbuWs.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '20.117.208.30' (ED25519) to the list of known hosts.
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.11.0-1018-azure x86_64)
...
azureuser@ciikorrr:~$
```

### Créez une VM depuis le Azure CLI

```bash
└─$ az vm create -g Cloud_Computing -n TP1_test --image Ubuntu2404 --admin-username azureciikorrr --ssh-key-values ~/.ssh/cloud_tp1.pub --size Standard_B1s
{
  "fqdns": "",
  "id": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/Cloud_Computing/providers/Microsoft.Compute/virtualMachines/TP1_test",
  "location": "uksouth",
  "macAddress": "60-45-BD-D0-3F-63",
  "powerState": "VM running",
  "privateIpAddress": "172.16.0.5",
  "publicIpAddress": "172.166.165.213",
  "resourceGroup": "Cloud_Computing",
  "zones": ""
}
```

### Assurez-vous que vous pouvez vous connecter à la VM en SSH sur son IP publique

```bash
ssh azureciikorrr@172.166.165.213
The authenticity of host '172.166.165.213 (172.166.165.213)' can't be established.
ED25519 key fingerprint is SHA256:l9g9jJguPk4cgIn7/LEGL4/RfiWxxkXQ/tj4l7BOtaY.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '172.166.165.213' (ED25519) to the list of known hosts.
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.11.0-1018-azure x86_64)
...
azureciikorrr@TP1test:~$
```

### Une fois connecté, prouvez la présence...
- ...du service walinuxagent.service

```bash
azureciikorrr@TP1test:~$ systemctl list-units --type=service | grep walinuxagent
  walinuxagent.service                                  loaded active running Azure Linux Agent
```
- ...du service cloud-init.service

```bash
azureciikorrr@TP1test:~$ systemctl list-units --type=service | grep cloud-init.service
  cloud-init.service                                    loaded active exited  Cloud-init: Network Stage
```

## 3 Prerequis Terraform

```bash
└─$ terraform init

Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/azurerm...
- Installing hashicorp/azurerm v4.43.0...
- Installed hashicorp/azurerm v4.43.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```bash
└─$ terraform plan


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_linux_virtual_machine.main will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_username                                         = "ciikorrr"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = (known after apply)
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "uksouth"
      + max_bid_price                                          = -1
      + name                                                   = "terraform_ciikorrr"
      + network_interface_ids                                  = (known after apply)
      + os_managed_disk_id                                     = (known after apply)
      + patch_assessment_mode                                  = (known after apply)
      + patch_mode                                             = (known after apply)
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = (known after apply)
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "Cloud_Computing"
      + size                                                   = "Standard_B1s"
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + admin_ssh_key {
          + public_key = <<-EOT
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmfJqNOWKGa5MUJBoBtOqsq5IUdHDjQpRQbCSLbxVM8 M.M@fedora
            EOT
          + username   = "ciikorrr"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = "vm-os-disk"
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "0001-com-ubuntu-server-focal"
          + publisher = "Canonical"
          + sku       = "20_04-lts"
          + version   = "latest"
        }

      + termination_notification (known after apply)
    }

  # azurerm_network_interface.main will be created
  + resource "azurerm_network_interface" "main" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "uksouth"
      + mac_address                    = (known after apply)
      + name                           = "vm-nic"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "Cloud_Computing"
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_public_ip.main will be created
  + resource "azurerm_public_ip" "main" {
      + allocation_method       = "Dynamic"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "uksouth"
      + name                    = "vm-ip"
      + resource_group_name     = "Cloud_Computing"
      + sku                     = "Basic"
      + sku_tier                = "Regional"
    }

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "Cloud_Computing"
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefixes                              = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "vm-subnet"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "Cloud_Computing"
      + virtual_network_name                          = "vm-vnet"
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space                  = [
          + "10.0.0.0/16",
        ]
      + dns_servers                    = (known after apply)
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "uksouth"
      + name                           = "vm-vnet"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "Cloud_Computing"
      + subnet                         = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

### Prouvez avec une connexion SSH sur l'IP publique que la VM est up

```bash
└─$ ssh ciikorrr@4.234.216.30
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.11.0-1018-azure x86_64)
...
ciikorrr@terraform-ciikorrr:~$
```

