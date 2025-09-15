output "url" {
  value       = azurerm_function_app_function.faf.invocation_url
  sensitive   = false
  description = "description"
}
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
}