variable "name_function" {
  type        = string
  description = "Name for the Azure Function App and related resources"
  validation {
    condition     = length(var.name_function) >= 3 && length(var.name_function) <= 24
    error_message = "The name_function must be between 3 and 24 characters long."
  }
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region where resources will be created"
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "Central US",
      "North Central US", "South Central US", "West Central US",
      "North Europe", "West Europe", "UK South", "UK West",
      "Southeast Asia", "East Asia", "Australia East", "Australia Southeast"
    ], var.location)
    error_message = "The location must be a valid Azure region."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "terraform-vm-project"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
  default     = "DevOps Team"
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machine"
  default     = "Standard_B1s"
  validation {
    condition = contains([
      "Standard_B1s", "Standard_B1ms", "Standard_B2s", "Standard_B2ms",
      "Standard_D2s_v3", "Standard_D4s_v3", "Standard_DS1_v2", "Standard_DS2_v2"
    ], var.vm_size)
    error_message = "VM size must be a valid Azure VM size."
  }
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR block allowed for SSH access"
  default     = "0.0.0.0/0"  # WARNING: Restrict this in production!
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "The allowed_ssh_cidr must be a valid CIDR block."
  }
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
  validation {
    condition     = length(var.admin_username) >= 3 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 3 and 20 characters long."
  }
}

variable "enable_data_disk" {
  type        = bool
  description = "Enable additional data disk for the VM"
  default     = false
}

variable "data_disk_size" {
  type        = number
  description = "Size of the data disk in GB"
  default     = 100
  validation {
    condition     = var.data_disk_size >= 1 && var.data_disk_size <= 32767
    error_message = "Data disk size must be between 1 and 32767 GB."
  }
}

variable "enable_snapshots" {
  type        = bool
  description = "Enable manual snapshots for the VM"
  default     = false
}
