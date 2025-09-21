# TP 3 AZ 104 Build your own lil' thingie

# TP Azure – Infrastructure automatisée avec Terraform

## Résumé du projet

Dans ce TP, j’ai déployé une infrastructure Azure répondant aux contraintes suivantes :  
- **Deux machines virtuelles** : un **reverse proxy** (nœud frontal) et un **bastion**.  
- **Un seul point d’entrée Internet** : le reverse proxy.  
- **Déploiement entièrement automatisé** avec **Terraform**.  
- **Monitoring** système et applicatif via **Netdata**.  
- **Backups** des fichiers de configuration et scripts vers un **Blob Storage Azure**.  
- **Sécurité renforcée** : clés SSH fortes, pas de connexion root, firewall local, NSG filtrant les ports.  
- **Azure features utilisées** :
  - `azurerm_key_vault_certificate` (HTTPS)
  - `azurerm_storage_container` (Backups)
  - `azurerm_network_security_group` (NSG)
  - `azurerm_key_vault` (Vault) 

---

## 1. Architecture mise en place

- **VM Reverse Proxy**  
  - Exposée sur Internet.  
  - Fonctionne comme **nœud frontal**.  
  - Services ouverts : **HTTP (80)**, **HTTPS (443)**, **SSH (22)**.  
  - Configurée avec un **certificat TLS** via `azurerm_key_vault_certificate`.  
  - Assure la sécurité en contrôlant les flux entrants.  

- **VM Bastion**  
  - Non exposée directement sur Internet.  
  - Accessible uniquement en SSH via le reverse proxy (rebond).  
  - Héberge :  
    - **Nginx (page par défaut)**
    - **Page Web** (Hello World)
    - **Netdata** pour le monitoring (port **19999** ouvert uniquement en interne).  

- **Réseau privé Azure**  
  - Les deux VMs communiquent via un **subnet commun**.  

---

## 2. Automatisation et configuration

- **Terraform** :  
  - Déploiement complet des ressources Azure.  
  - Création des VMs, réseau privé, NSG, Blob Storage, certificats, etc.  

- **Scripts d’automatisation & Cloud-init** :  
  - Installation de **Nginx** et **Netdata**.  
  - Configuration de la sécurité (désactivation root, SSH par clés, firewall local).  
  - Mise en place des répertoires de sauvegarde dans `/var/backups`.  

---

## 3. Sécurité

- **Bonnes pratiques appliquées** :  
  - Pas de connexion root locale ou distante.  
  - SSH uniquement par clés fortes (pas de mots de passe).  
  - Droits et permissions correctement gérés sur les fichiers sensibles (700 pour les scripts et 744 pour les fichiers de config).  
  - **Firewall local** configuré sur chaque VM :  
    - **Reverse proxy** : 22, 80, 443.  
    - **Bastion** : 22, 19999 (Netdata).  

- **NSG Azure (`azurerm_network_security_group`)** :  
  - Filtrage des ports **443, 80, 22, 19999**.  
  - Application au subnet contenant les deux VMs.  

---

## 4. Monitoring

- **Netdata** :  
  - Collecte de métriques systèmes (CPU, RAM, disque).  
  - Vérification des services applicatifs (Nginx en fonctionnement).  
  - Vérification réseau (ports).  

---

## 5. Backups

- **Blob Storage Azure (`azurerm_storage_container`)** :  
  - Centralisation des sauvegardes.  
  - Sauvegarde automatique des fichiers de configuration critiques :  azurerm_blob_storage
    - Configurations SSH
    - Configurations Nginx  
    - Scripts d’installation et d’automatisation 
  - Stockage dans `/var/backups`.  

---

## 6. Azure Features utilisées

- **Azure Network Security Group (NSG)** – filtrage réseau.  
- **Azure Blob Storage** – sauvegardes.  
- **Azure Certificates (`azurerm_key_vault_certificate`)** – gestion HTTPS.  
- **Monitoring & métriques** via Netdata intégré aux VMs.  

---

## 7. Process de deployement

- 1. Lancement du terraform **`terraform apply`**
- 2. Installation des différents **scripts d'installation et de configuration** dans les VM grâce au cloud-init
- 3. Utilisation de **runcmd** afin d'executer les scripts sur les VM respective (attendre quelques minutes que tout se fasse, ~ 3min)
- 4. Process terminé, reception d'un test du monitoring des metrics sur le webhook discord

```
└─$ terraform apply  
data.azurerm_client_config.current: Reading...
data.azurerm_client_config.current: Read complete after 0s [id=Y2xpZW50Q29uZmlncy9jbGllbnRJZD0wNGIwNzc5NS04ZGRiLTQ2MWEtYmJlZS0wMmY5ZTFiZjdiNDY7b2JqZWN0SWQ9OWI4NWVkNDQtMmQyNi00NGI2LTgzNDMtNTJlZjZmNDVjYjcyO3N1YnNjcmlwdGlvbklkPWI0NWI0Y2JlLWE4OTEtNGFhZi1hNTBlLTc0ZjA3ZGFhMTRiMDt0ZW5hbnRJZD00MTM2MDBjZi1iZDRlLTRjN2MtOGE2MS02OWU3M2NkZGY3MzE=]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.azurerm_virtual_machine.myVirtualMachine will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "azurerm_virtual_machine" "myVirtualMachine" {
      + id                   = (known after apply)
      + identity             = (known after apply)
      + location             = (known after apply)
      + name                 = "az-ciikorrr-backend"
      + power_state          = (known after apply)
      + private_ip_address   = (known after apply)
      + private_ip_addresses = (known after apply)
      + public_ip_address    = (known after apply)
      + public_ip_addresses  = (known after apply)
      + resource_group_name  = "AZ-RG"
    }

  # azurerm_key_vault.myVault will be created
  + resource "azurerm_key_vault" "myVault" {
      + access_policy                 = [
          + {
              + certificate_permissions = [
                  + "Create",
                  + "Delete",
                  + "DeleteIssuers",
                  + "Get",
                  + "GetIssuers",
                  + "Import",
                  + "List",
                  + "ListIssuers",
                  + "ManageContacts",
                  + "ManageIssuers",
                  + "Purge",
                  + "SetIssuers",
                  + "Update",
                ]
              + key_permissions         = [
                  + "Backup",
                  + "Create",
                  + "Decrypt",
                  + "Delete",
                  + "Encrypt",
                  + "Get",
                  + "Import",
                  + "List",
                  + "Purge",
                  + "Recover",
                  + "Restore",
                  + "Sign",
                  + "UnwrapKey",
                  + "Update",
                  + "Verify",
                  + "WrapKey",
                ]
              + object_id               = "9b85ed44-2d26-44b6-8343-52ef6f45cb72"
              + secret_permissions      = [
                  + "Backup",
                  + "Delete",
                  + "Get",
                  + "List",
                  + "Purge",
                  + "Recover",
                  + "Restore",
                  + "Set",
                ]
              + tenant_id               = "413600cf-bd4e-4c7c-8a61-69e73cddf731"
            },
        ]
      + enable_rbac_authorization     = (known after apply)
      + id                            = (known after apply)
      + location                      = "uksouth"
      + name                          = "ciikorrrVault"
      + public_network_access_enabled = true
      + rbac_authorization_enabled    = (known after apply)
      + resource_group_name           = "AZ-RG"
      + sku_name                      = "standard"
      + soft_delete_retention_days    = 7
      + tenant_id                     = "413600cf-bd4e-4c7c-8a61-69e73cddf731"
      + vault_uri                     = (known after apply)

      + contact (known after apply)

      + network_acls (known after apply)
    }

  # azurerm_key_vault_certificate.myVaultCertificate will be created
  + resource "azurerm_key_vault_certificate" "myVaultCertificate" {
      + certificate_attribute           = (known after apply)
      + certificate_data                = (known after apply)
      + certificate_data_base64         = (known after apply)
      + id                              = (known after apply)
      + key_vault_id                    = (known after apply)
      + name                            = "ciikorrr-cert"
      + resource_manager_id             = (known after apply)
      + resource_manager_versionless_id = (known after apply)
      + secret_id                       = (known after apply)
      + thumbprint                      = (known after apply)
      + version                         = (known after apply)
      + versionless_id                  = (known after apply)
      + versionless_secret_id           = (known after apply)

      + certificate_policy {
          + issuer_parameters {
              + name = "Self"
            }
          + key_properties {
              + curve      = (known after apply)
              + exportable = true
              + key_size   = 2048
              + key_type   = "RSA"
              + reuse_key  = true
            }
          + lifetime_action {
              + action {
                  + action_type = "AutoRenew"
                }
              + trigger {
                  + days_before_expiry = 30
                }
            }
          + secret_properties {
              + content_type = "application/x-pkcs12"
            }
          + x509_certificate_properties {
              + extended_key_usage = [
                  + "1.3.6.1.5.5.7.3.1",
                ]
              + key_usage          = [
                  + "cRLSign",
                  + "dataEncipherment",
                  + "digitalSignature",
                  + "keyAgreement",
                  + "keyCertSign",
                  + "keyEncipherment",
                ]
              + subject            = "CN=hello-world"
              + validity_in_months = 12

              + subject_alternative_names {
                  + dns_names = [
                      + "ciikorrrdomaine",
                    ]
                }
            }
        }
    }

  # azurerm_linux_virtual_machine.myLinuxVirtualMachine_1 will be created
  + resource "azurerm_linux_virtual_machine" "myLinuxVirtualMachine_1" {
      + admin_username                                         = "ciikorrr"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + custom_data                                            = (sensitive value)
      + disable_password_authentication                        = (known after apply)
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "uksouth"
      + max_bid_price                                          = -1
      + name                                                   = "az-ciikorrr-frontend"
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
      + resource_group_name                                    = "AZ-RG"
      + size                                                   = "Standard_B1s"
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + admin_ssh_key {
          + public_key = <<-EOT
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIx77OCib7Hs85f2S8g1hT6KHB6HdB44X5g3lYvsuvbV M.M@fedora
            EOT
          + username   = "ciikorrr"
        }

      + identity {
          + principal_id = (known after apply)
          + tenant_id    = (known after apply)
          + type         = "SystemAssigned"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = "vm1-os-disk"
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

  # azurerm_linux_virtual_machine.myLinuxVirtualMachine_2 will be created
  + resource "azurerm_linux_virtual_machine" "myLinuxVirtualMachine_2" {
      + admin_username                                         = "ciikorrr"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + custom_data                                            = (sensitive value)
      + disable_password_authentication                        = (known after apply)
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "uksouth"
      + max_bid_price                                          = -1
      + name                                                   = "az-ciikorrr-backend"
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
      + resource_group_name                                    = "AZ-RG"
      + size                                                   = "Standard_B1s"
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + admin_ssh_key {
          + public_key = <<-EOT
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIx77OCib7Hs85f2S8g1hT6KHB6HdB44X5g3lYvsuvbV M.M@fedora
            EOT
          + username   = "ciikorrr"
        }

      + identity {
          + principal_id = (known after apply)
          + tenant_id    = (known after apply)
          + type         = "SystemAssigned"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = "vm2-os-disk"
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

  # azurerm_network_interface.myNic_backend will be created
  + resource "azurerm_network_interface" "myNic_backend" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "uksouth"
      + mac_address                    = (known after apply)
      + name                           = "vm-nic-2"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "AZ-RG"
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = "10.0.1.4"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_network_interface.myNic_frontend will be created
  + resource "azurerm_network_interface" "myNic_frontend" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "uksouth"
      + mac_address                    = (known after apply)
      + name                           = "vm-nic-1"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "AZ-RG"
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = "10.0.1.5"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_network_security_group.myVM_NSG will be created
  + resource "azurerm_network_security_group" "myVM_NSG" {
      + id                  = (known after apply)
      + location            = "uksouth"
      + name                = "vm-nsg"
      + resource_group_name = "AZ-RG"
      + security_rule       = (known after apply)
    }

  # azurerm_network_security_rule.allow_http will be created
  + resource "azurerm_network_security_rule" "allow_http" {
      + access                      = "Allow"
      + destination_address_prefix  = "*"
      + destination_port_range      = "80"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "Allow-HTTP"
      + network_security_group_name = "vm-nsg"
      + priority                    = 100
      + protocol                    = "Tcp"
      + resource_group_name         = "AZ-RG"
      + source_address_prefix       = "*"
      + source_port_range           = "*"
    }

  # azurerm_network_security_rule.allow_https will be created
  + resource "azurerm_network_security_rule" "allow_https" {
      + access                      = "Allow"
      + destination_address_prefix  = "*"
      + destination_port_range      = "443"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "Allow-HTTPS"
      + network_security_group_name = "vm-nsg"
      + priority                    = 110
      + protocol                    = "Tcp"
      + resource_group_name         = "AZ-RG"
      + source_address_prefix       = "*"
      + source_port_range           = "*"
    }

  # azurerm_network_security_rule.allow_netdata will be created
  + resource "azurerm_network_security_rule" "allow_netdata" {
      + access                      = "Allow"
      + destination_address_prefix  = "*"
      + destination_port_range      = "19999"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "Allow-netdata"
      + network_security_group_name = "vm-nsg"
      + priority                    = 1001
      + protocol                    = "Tcp"
      + resource_group_name         = "AZ-RG"
      + source_address_prefix       = "*"
      + source_port_range           = "*"
    }

  # azurerm_network_security_rule.allow_ssh will be created
  + resource "azurerm_network_security_rule" "allow_ssh" {
      + access                      = "Allow"
      + destination_address_prefix  = "*"
      + destination_port_range      = "22"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "Allow-SSH"
      + network_security_group_name = "vm-nsg"
      + priority                    = 120
      + protocol                    = "Tcp"
      + resource_group_name         = "AZ-RG"
      + source_address_prefix       = "*"
      + source_port_range           = "*"
    }

  # azurerm_network_security_rule.allow_vnet will be created
  + resource "azurerm_network_security_rule" "allow_vnet" {
      + access                      = "Allow"
      + destination_address_prefix  = "VirtualNetwork"
      + destination_port_range      = "*"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "Allow-VNet"
      + network_security_group_name = "vm-nsg"
      + priority                    = 200
      + protocol                    = "*"
      + resource_group_name         = "AZ-RG"
      + source_address_prefix       = "VirtualNetwork"
      + source_port_range           = "*"
    }

  # azurerm_public_ip.myFront_Public_IP will be created
  + resource "azurerm_public_ip" "myFront_Public_IP" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + domain_name_label       = "ciikorrrdomaine"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "uksouth"
      + name                    = "vm-ip"
      + resource_group_name     = "AZ-RG"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
    }

  # azurerm_resource_group.myRessourceGroup will be created
  + resource "azurerm_resource_group" "myRessourceGroup" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "AZ-RG"
    }

  # azurerm_role_assignment.vm_blob_access will be created
  + resource "azurerm_role_assignment" "vm_blob_access" {
      + condition_version                = (known after apply)
      + id                               = (known after apply)
      + name                             = (known after apply)
      + principal_id                     = (known after apply)
      + principal_type                   = (known after apply)
      + role_definition_id               = (known after apply)
      + role_definition_name             = "Storage Blob Data Contributor"
      + scope                            = (known after apply)
      + skip_service_principal_aad_check = (known after apply)
    }

  # azurerm_storage_account.myAccount will be created
  + resource "azurerm_storage_account" "myAccount" {
      + access_tier                        = (known after apply)
      + account_kind                       = "StorageV2"
      + account_replication_type           = "LRS"
      + account_tier                       = "Standard"
      + allow_nested_items_to_be_public    = true
      + cross_tenant_replication_enabled   = false
      + default_to_oauth_authentication    = false
      + dns_endpoint_type                  = "Standard"
      + https_traffic_only_enabled         = true
      + id                                 = (known after apply)
      + infrastructure_encryption_enabled  = false
      + is_hns_enabled                     = false
      + large_file_share_enabled           = (known after apply)
      + local_user_enabled                 = true
      + location                           = "uksouth"
      + min_tls_version                    = "TLS1_2"
      + name                               = "ciikorrrstorage"
      + nfsv3_enabled                      = false
      + primary_access_key                 = (sensitive value)
      + primary_blob_connection_string     = (sensitive value)
      + primary_blob_endpoint              = (known after apply)
      + primary_blob_host                  = (known after apply)
      + primary_blob_internet_endpoint     = (known after apply)
      + primary_blob_internet_host         = (known after apply)
      + primary_blob_microsoft_endpoint    = (known after apply)
      + primary_blob_microsoft_host        = (known after apply)
      + primary_connection_string          = (sensitive value)
      + primary_dfs_endpoint               = (known after apply)
      + primary_dfs_host                   = (known after apply)
      + primary_dfs_internet_endpoint      = (known after apply)
      + primary_dfs_internet_host          = (known after apply)
      + primary_dfs_microsoft_endpoint     = (known after apply)
      + primary_dfs_microsoft_host         = (known after apply)
      + primary_file_endpoint              = (known after apply)
      + primary_file_host                  = (known after apply)
      + primary_file_internet_endpoint     = (known after apply)
      + primary_file_internet_host         = (known after apply)
      + primary_file_microsoft_endpoint    = (known after apply)
      + primary_file_microsoft_host        = (known after apply)
      + primary_location                   = (known after apply)
      + primary_queue_endpoint             = (known after apply)
      + primary_queue_host                 = (known after apply)
      + primary_queue_microsoft_endpoint   = (known after apply)
      + primary_queue_microsoft_host       = (known after apply)
      + primary_table_endpoint             = (known after apply)
      + primary_table_host                 = (known after apply)
      + primary_table_microsoft_endpoint   = (known after apply)
      + primary_table_microsoft_host       = (known after apply)
      + primary_web_endpoint               = (known after apply)
      + primary_web_host                   = (known after apply)
      + primary_web_internet_endpoint      = (known after apply)
      + primary_web_internet_host          = (known after apply)
      + primary_web_microsoft_endpoint     = (known after apply)
      + primary_web_microsoft_host         = (known after apply)
      + public_network_access_enabled      = true
      + queue_encryption_key_type          = "Service"
      + resource_group_name                = "AZ-RG"
      + secondary_access_key               = (sensitive value)
      + secondary_blob_connection_string   = (sensitive value)
      + secondary_blob_endpoint            = (known after apply)
      + secondary_blob_host                = (known after apply)
      + secondary_blob_internet_endpoint   = (known after apply)
      + secondary_blob_internet_host       = (known after apply)
      + secondary_blob_microsoft_endpoint  = (known after apply)
      + secondary_blob_microsoft_host      = (known after apply)
      + secondary_connection_string        = (sensitive value)
      + secondary_dfs_endpoint             = (known after apply)
      + secondary_dfs_host                 = (known after apply)
      + secondary_dfs_internet_endpoint    = (known after apply)
      + secondary_dfs_internet_host        = (known after apply)
      + secondary_dfs_microsoft_endpoint   = (known after apply)
      + secondary_dfs_microsoft_host       = (known after apply)
      + secondary_file_endpoint            = (known after apply)
      + secondary_file_host                = (known after apply)
      + secondary_file_internet_endpoint   = (known after apply)
      + secondary_file_internet_host       = (known after apply)
      + secondary_file_microsoft_endpoint  = (known after apply)
      + secondary_file_microsoft_host      = (known after apply)
      + secondary_location                 = (known after apply)
      + secondary_queue_endpoint           = (known after apply)
      + secondary_queue_host               = (known after apply)
      + secondary_queue_microsoft_endpoint = (known after apply)
      + secondary_queue_microsoft_host     = (known after apply)
      + secondary_table_endpoint           = (known after apply)
      + secondary_table_host               = (known after apply)
      + secondary_table_microsoft_endpoint = (known after apply)
      + secondary_table_microsoft_host     = (known after apply)
      + secondary_web_endpoint             = (known after apply)
      + secondary_web_host                 = (known after apply)
      + secondary_web_internet_endpoint    = (known after apply)
      + secondary_web_internet_host        = (known after apply)
      + secondary_web_microsoft_endpoint   = (known after apply)
      + secondary_web_microsoft_host       = (known after apply)
      + sftp_enabled                       = false
      + shared_access_key_enabled          = true
      + table_encryption_key_type          = "Service"

      + blob_properties (known after apply)

      + network_rules (known after apply)

      + queue_properties (known after apply)

      + routing (known after apply)

      + share_properties (known after apply)

      + static_website (known after apply)
    }

  # azurerm_storage_container.myContainer will be created
  + resource "azurerm_storage_container" "myContainer" {
      + container_access_type             = "private"
      + default_encryption_scope          = (known after apply)
      + encryption_scope_override_enabled = true
      + has_immutability_policy           = (known after apply)
      + has_legal_hold                    = (known after apply)
      + id                                = (known after apply)
      + metadata                          = (known after apply)
      + name                              = "mycontainer"
      + resource_manager_id               = (known after apply)
      + storage_account_id                = (known after apply)
    }

  # azurerm_subnet.mySubnet will be created
  + resource "azurerm_subnet" "mySubnet" {
      + address_prefixes                              = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "vm-subnet"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "AZ-RG"
      + virtual_network_name                          = "vm-vnet"
    }

  # azurerm_subnet_network_security_group_association.subnet_assoc will be created
  + resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
      + id                        = (known after apply)
      + network_security_group_id = (known after apply)
      + subnet_id                 = (known after apply)
    }

  # azurerm_virtual_network.myVNet will be created
  + resource "azurerm_virtual_network" "myVNet" {
      + address_space                  = [
          + "10.0.0.0/16",
        ]
      + dns_servers                    = (known after apply)
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "uksouth"
      + name                           = "vm-vnet"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "AZ-RG"
      + subnet                         = (known after apply)
    }

Plan: 20 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + MyPublicDNS         = (known after apply)
  + MyVmPublicIPAddress = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.myRessourceGroup: Creating...
azurerm_virtual_network.myVNet: Creating...
azurerm_public_ip.myFront_Public_IP: Creating...
azurerm_virtual_network.myVNet: Creation complete after 6s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/virtualNetworks/vm-vnet]
azurerm_subnet.mySubnet: Creating...
azurerm_public_ip.myFront_Public_IP: Creation complete after 6s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/publicIPAddresses/vm-ip]
azurerm_resource_group.myRessourceGroup: Still creating... [00m10s elapsed]
azurerm_subnet.mySubnet: Creation complete after 5s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/virtualNetworks/vm-vnet/subnets/vm-subnet]
azurerm_network_interface.myNic_backend: Creating...
azurerm_network_interface.myNic_frontend: Creating...
azurerm_resource_group.myRessourceGroup: Creation complete after 11s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG]
azurerm_network_security_group.myVM_NSG: Creating...
azurerm_key_vault.myVault: Creating...
azurerm_storage_account.myAccount: Creating...
azurerm_network_interface.myNic_frontend: Creation complete after 2s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkInterfaces/vm-nic-1]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_1: Creating...
azurerm_network_security_group.myVM_NSG: Creation complete after 3s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkSecurityGroups/vm-nsg]
azurerm_network_security_rule.allow_ssh: Creating...
azurerm_network_security_rule.allow_netdata: Creating...
azurerm_network_security_rule.allow_vnet: Creating...
azurerm_subnet_network_security_group_association.subnet_assoc: Creating...
azurerm_network_security_rule.allow_https: Creating...
azurerm_network_security_rule.allow_http: Creating...
azurerm_network_security_rule.allow_https: Creation complete after 2s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkSecurityGroups/vm-nsg/securityRules/Allow-HTTPS]
azurerm_network_security_rule.allow_vnet: Creation complete after 2s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkSecurityGroups/vm-nsg/securityRules/Allow-VNet]
azurerm_network_security_rule.allow_http: Creation complete after 2s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkSecurityGroups/vm-nsg/securityRules/Allow-HTTP]
azurerm_network_interface.myNic_backend: Still creating... [00m10s elapsed]
azurerm_key_vault.myVault: Still creating... [00m10s elapsed]
azurerm_storage_account.myAccount: Still creating... [00m10s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_1: Still creating... [00m10s elapsed]
azurerm_network_interface.myNic_backend: Creation complete after 13s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkInterfaces/vm-nic-2]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_2: Creating...
azurerm_network_security_rule.allow_ssh: Still creating... [00m10s elapsed]
azurerm_subnet_network_security_group_association.subnet_assoc: Still creating... [00m10s elapsed]
azurerm_network_security_rule.allow_netdata: Still creating... [00m10s elapsed]
azurerm_subnet_network_security_group_association.subnet_assoc: Creation complete after 15s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/virtualNetworks/vm-vnet/subnets/vm-subnet]
azurerm_network_security_rule.allow_ssh: Creation complete after 15s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkSecurityGroups/vm-nsg/securityRules/Allow-SSH]
azurerm_network_security_rule.allow_netdata: Creation complete after 16s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Network/networkSecurityGroups/vm-nsg/securityRules/Allow-netdata]
azurerm_key_vault.myVault: Still creating... [00m20s elapsed]
azurerm_storage_account.myAccount: Still creating... [00m20s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_1: Still creating... [00m20s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_2: Still creating... [00m10s elapsed]
azurerm_key_vault.myVault: Still creating... [00m30s elapsed]
azurerm_storage_account.myAccount: Still creating... [00m30s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_1: Still creating... [00m30s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_2: Still creating... [00m20s elapsed]
azurerm_key_vault.myVault: Still creating... [00m40s elapsed]
azurerm_storage_account.myAccount: Still creating... [00m40s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_1: Still creating... [00m40s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_2: Still creating... [00m30s elapsed]
azurerm_key_vault.myVault: Still creating... [00m50s elapsed]
azurerm_storage_account.myAccount: Still creating... [00m50s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_1: Still creating... [00m50s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_1: Creation complete after 51s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Compute/virtualMachines/az-ciikorrr-frontend]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_2: Still creating... [00m40s elapsed]
azurerm_key_vault.myVault: Still creating... [01m00s elapsed]
azurerm_storage_account.myAccount: Still creating... [01m01s elapsed]
azurerm_linux_virtual_machine.myLinuxVirtualMachine_2: Creation complete after 48s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Compute/virtualMachines/az-ciikorrr-backend]
data.azurerm_virtual_machine.myVirtualMachine: Reading...
data.azurerm_virtual_machine.myVirtualMachine: Read complete after 1s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Compute/virtualMachines/az-ciikorrr-backend]
azurerm_key_vault.myVault: Still creating... [01m10s elapsed]
azurerm_storage_account.myAccount: Still creating... [01m11s elapsed]
azurerm_storage_account.myAccount: Creation complete after 1m11s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Storage/storageAccounts/ciikorrrstorage]
azurerm_role_assignment.vm_blob_access: Creating...
azurerm_storage_container.myContainer: Creating...
azurerm_storage_container.myContainer: Creation complete after 1s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Storage/storageAccounts/ciikorrrstorage/blobServices/default/containers/mycontainer]
azurerm_key_vault.myVault: Still creating... [01m20s elapsed]
azurerm_role_assignment.vm_blob_access: Still creating... [00m10s elapsed]
azurerm_key_vault.myVault: Still creating... [01m30s elapsed]
azurerm_role_assignment.vm_blob_access: Still creating... [00m20s elapsed]
azurerm_role_assignment.vm_blob_access: Creation complete after 24s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.Storage/storageAccounts/ciikorrrstorage/providers/Microsoft.Authorization/roleAssignments/c5f0ff01-8ec8-dcca-3cc7-2a9461749744]
azurerm_key_vault.myVault: Still creating... [01m40s elapsed]
azurerm_key_vault.myVault: Still creating... [01m50s elapsed]
azurerm_key_vault.myVault: Still creating... [02m00s elapsed]
azurerm_key_vault.myVault: Still creating... [02m10s elapsed]
azurerm_key_vault.myVault: Still creating... [02m21s elapsed]
azurerm_key_vault.myVault: Still creating... [02m31s elapsed]
azurerm_key_vault.myVault: Creation complete after 2m36s [id=/subscriptions/b45b4cbe-a891-4aaf-a50e-74f07daa14b0/resourceGroups/AZ-RG/providers/Microsoft.KeyVault/vaults/ciikorrrVault]
azurerm_key_vault_certificate.myVaultCertificate: Creating...
azurerm_key_vault_certificate.myVaultCertificate: Still creating... [00m10s elapsed]
azurerm_key_vault_certificate.myVaultCertificate: Creation complete after 16s [id=https://ciikorrrvault.vault.azure.net/certificates/ciikorrr-cert/b69c587511694441925535d862040caa]

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

MyPublicDNS = "ciikorrrdomaine.uksouth.cloudapp.azure.com"
MyVmPublicIPAddress = "172.167.184.67"
```

## Conclusion

Cette infrastructure répond à toutes les contraintes du TP :  
- Deux VMs en réseau privé.  
- Un seul nœud frontal exposé.  
- Accès administrateur sécurisé via rebond SSH.  
- Monitoring, sauvegardes et bonnes pratiques de sécurité mises en place.  
- Déploiement entièrement automatisé grâce à Terraform, Bash et aux services Azure.
