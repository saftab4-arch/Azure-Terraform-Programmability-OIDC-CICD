resource "azurerm_resource_group" "lab4" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "lab4" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.lab4.location
  resource_group_name = azurerm_resource_group.lab4.name
  address_space       = ["10.20.0.0/16"]

  tags = local.common_tags
}


resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = "${local.name_prefix}-${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.lab4.name
  virtual_network_name = azurerm_virtual_network.lab4.name
  address_prefixes     = [each.value.address_prefix]
}


resource "azurerm_network_security_group" "nsgs" {
  for_each = var.subnets

  name                = "${local.name_prefix}-${each.key}-nsg"
  location            = azurerm_resource_group.lab4.location
  resource_group_name = azurerm_resource_group.lab4.name

  tags = local.common_tags
}


resource "azurerm_subnet_network_security_group_association" "nsg_associations" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsgs[each.key].id
}


resource "azurerm_network_security_rule" "tier_rules" {
  for_each = var.subnets

  name      = "Allow-${each.value.tier}"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = each.value.tier == "frontend" ? "80" : each.value.tier == "application" ? "8080" : "5432"

  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab4.name
  network_security_group_name = azurerm_network_security_group.nsgs[each.key].name
}

resource "azurerm_network_interface" "nics" {
  for_each = var.subnets

  name                = "${local.name_prefix}-${each.key}-nic"
  location            = azurerm_resource_group.lab4.location
  resource_group_name = azurerm_resource_group.lab4.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}



resource "azurerm_linux_virtual_machine" "vms" {
  for_each = var.subnets

  name                = "${local.name_prefix}-${each.key}-vm"
  resource_group_name = azurerm_resource_group.lab4.name
  location            = azurerm_resource_group.lab4.location

  size           = local.vm_size
  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nics[each.key].id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/syedaftab04/.ssh/terraform-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}


