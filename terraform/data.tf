data "azurerm_resource_group" "fatima" {
  name = "Fatima"
}

data "azurerm_virtual_machine" "naukri" {
  name                = "Naukri"
  resource_group_name = data.azurerm_resource_group.fatima.name
}