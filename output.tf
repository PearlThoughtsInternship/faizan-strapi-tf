output "vm_public_ip" {
  value       = azurerm_public_ip.faizan-rg123.ip_address
  description = "The Public IP address of the server instance."
}

