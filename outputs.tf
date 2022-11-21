output "container_fqdn" {
  value = "http://${azurerm_container_group.main.fqdn}"
}