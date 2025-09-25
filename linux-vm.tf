resource "azurerm_resource_group" "linuxvm" {
  name     = "linux-virtual-machine"
  location = "Canada East"
}

resource "azurerm_virtual_network" "network1" {
  name                = "linux-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.linuxvm.location
  resource_group_name = azurerm_resource_group.linuxvm.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "linux-internal"
  resource_group_name  = azurerm_resource_group.linuxvm.name
  virtual_network_name = azurerm_virtual_network.network1.name
  address_prefixes     = ["192.10.2.0/24"]
}

resource "azurerm_network_interface" "networkinterface1" {
  name                = "linux-network-interface"
  location            = azurerm_resource_group.linuxvm.location
  resource_group_name = azurerm_resource_group.linuxvm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux1" {
  name                = "linux1-machine"
  resource_group_name = azurerm_resource_group.linuxvm.name
  location            = azurerm_resource_group.linuxvm.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.networkinterface1.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
