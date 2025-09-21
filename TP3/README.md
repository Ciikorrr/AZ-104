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

## Conclusion

Cette infrastructure répond à toutes les contraintes du TP :  
- Deux VMs en réseau privé.  
- Un seul nœud frontal exposé.  
- Accès administrateur sécurisé via rebond SSH.  
- Monitoring, sauvegardes et bonnes pratiques de sécurité mises en place.  
- Déploiement entièrement automatisé grâce à Terraform, Bash et aux services Azure.
