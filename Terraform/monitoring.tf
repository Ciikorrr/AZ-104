resource "azurerm_monitor_action_group" "myMonitor" {
  name                = "ag-${var.resource_group_name}-alerts"
  resource_group_name = azurerm_resource_group.myRessourceGroup.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email_address
  }
}

# CPU Metric Alert (using platform metrics)
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert-${azurerm_linux_virtual_machine.myLinuxVirtualMachine.name}"
  resource_group_name = azurerm_resource_group.myRessourceGroup.name
  scopes              = [azurerm_linux_virtual_machine.myLinuxVirtualMachine.id]
  description         = "Alert when CPU usage exceeds 70%"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  auto_mitigate = true

  action {
    action_group_id = azurerm_monitor_action_group.myMonitor.id
  }
}

resource "azurerm_monitor_metric_alert" "RAM_alert" {
  name                = "RAM-alert-${azurerm_linux_virtual_machine.myLinuxVirtualMachine.name}"
  resource_group_name = azurerm_resource_group.myRessourceGroup.name
  scopes              = [azurerm_linux_virtual_machine.myLinuxVirtualMachine.id]
  description         = "Alert when Memory available is less the 512M"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912 # 512 MB en bytes
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  auto_mitigate = true

  action {
    action_group_id = azurerm_monitor_action_group.myMonitor.id
  }
}