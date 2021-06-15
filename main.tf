provider "azurerm"{
    features {}
    subscription_id = "3a7cabe6-8f36-4652-84fe-65f0816271bf"
    client_id = "f8d6f3e9-52f6-40ef-bf96-c71d70a290b3"
    client_secret = "M.GH3I8q_Qdi1URR.Up4qbNPZt2xpW2m0Q"
    tenant_id = "2cda0f86-a393-434b-ae1b-368b0c9efb31"
}

variable "prefix" {
  default = "aman"
}

resource "azurerm_resource_group" "terraformRG" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraformRG.location
  resource_group_name = azurerm_resource_group.terraformRG.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.terraformRG.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.terraformRG.location
  resource_group_name = azurerm_resource_group.terraformRG.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.terraformRG.location
  resource_group_name   = azurerm_resource_group.terraformRG.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "amandevops"
    admin_password = "Devops@1234567"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    owner = "Aman Kumar Roy"
  }
}

