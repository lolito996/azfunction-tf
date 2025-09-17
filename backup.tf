# Backup and Disaster Recovery Resources

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "main" {
  name                = "${var.name_function}-backup-vault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  soft_delete_enabled = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
  }
}

# Backup Policy for VM
resource "azurerm_backup_policy_vm" "main" {
  name                = "${var.name_function}-backup-policy"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }

  retention_weekly {
    count    = 4
    weekdays = ["Sunday", "Wednesday"]
  }

  retention_monthly {
    count    = 12
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }

  retention_yearly {
    count    = 1
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}

# Backup Protection for VM
resource "azurerm_backup_protected_vm" "main" {
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_linux_virtual_machine.my_terraform_vm.id
  backup_policy_id    = azurerm_backup_policy_vm.main.id
}

# Managed Disk for additional storage (optional)
resource "azurerm_managed_disk" "data_disk" {
  count                = var.enable_data_disk ? 1 : 0
  name                 = "${var.name_function}-data-disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
  }
}

# Attach data disk to VM
resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  count              = var.enable_data_disk ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.data_disk[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.my_terraform_vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

# Snapshot policy for additional protection
resource "azurerm_snapshot" "vm_snapshot" {
  count               = var.enable_snapshots ? 1 : 0
  name                = "${var.name_function}-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  create_option       = "Copy"
  source_uri          = azurerm_linux_virtual_machine.my_terraform_vm.storage_os_disk[0].managed_disk_id

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
    Type        = "Manual Snapshot"
  }
}
