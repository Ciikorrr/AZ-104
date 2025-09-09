resource "azurerm_storage_account" "myAccount" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.myRessourceGroup.name
  location                 = azurerm_resource_group.myRessourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "myContainer" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.myAccount.id
  container_access_type = "private"
}

data "azurerm_virtual_machine" "myVirtualMachine" {
  name                = azurerm_linux_virtual_machine.myLinuxVirtualMachine.name
  resource_group_name = azurerm_resource_group.myRessourceGroup.name
}

resource "azurerm_role_assignment" "vm_blob_access" {
  principal_id = data.azurerm_virtual_machine.myVirtualMachine.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.myAccount.id

  depends_on = [
    azurerm_linux_virtual_machine.myLinuxVirtualMachine
  ]
}