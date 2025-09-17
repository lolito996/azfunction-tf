# Monitoring and Logging Resources

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_function}-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
  }
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.name_function}-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
  }
}

# VM Extension for monitoring
resource "azurerm_virtual_machine_extension" "monitoring" {
  name                 = "MonitoringAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.my_terraform_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"

  settings = jsonencode({
    workspaceId = azurerm_log_analytics_workspace.main.workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = azurerm_log_analytics_workspace.main.primary_shared_key
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
  }
}

# Diagnostic Settings for VM
resource "azurerm_monitor_diagnostic_setting" "vm_diagnostics" {
  name                       = "${var.name_function}-vm-diagnostics"
  target_resource_id         = azurerm_linux_virtual_machine.my_terraform_vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "BootDiagnostics"
  }

  enabled_log {
    category = "SystemEvent"
  }

  enabled_log {
    category = "SecurityEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Alert Rule for VM CPU
resource "azurerm_monitor_metric_alert" "vm_cpu" {
  name                = "${var.name_function}-vm-cpu-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine.my_terraform_vm.id]
  description         = "Alert when VM CPU usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
  }
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.name_function}-alerts"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"  # Replace with actual email
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
  }
}
