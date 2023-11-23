
resource "azurerm_resource_group" "faizan-rg123" {
  name     = "faizan-rg123"
  location = "northeurope"
}


resource "azurerm_virtual_network" "faizan-rg123" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.faizan-rg123.name
  location            = azurerm_resource_group.faizan-rg123.location
  address_space       = ["10.100.0.0/16"]

}


resource "azurerm_subnet" "faizan-rg123" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.faizan-rg123.name
  virtual_network_name = azurerm_virtual_network.faizan-rg123.name
  address_prefixes     = ["10.100.16.0/20"]
}



resource "azurerm_public_ip" "faizan-rg123" {
  name                = "vm_public_ip"
  location            = azurerm_resource_group.faizan-rg123.location
  resource_group_name = azurerm_resource_group.faizan-rg123.name
  allocation_method   = "Static"

}

data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.faizan-rg123.name
  resource_group_name = azurerm_resource_group.faizan-rg123.name
}



resource "azurerm_network_security_group" "faizan-rg123" {
  name                = "sec_group"
  location            = azurerm_resource_group.faizan-rg123.location
  resource_group_name = azurerm_resource_group.faizan-rg123.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
   security_rule {
    name                       = "allow-port-1337"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1337"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rds-3389"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

  #tags = {
 #   environment = "Production"
#  }
#}

resource "azurerm_network_interface" "faizan-rg123" {
  name                = "nic"
  location            = azurerm_resource_group.faizan-rg123.location
  resource_group_name = azurerm_resource_group.faizan-rg123.name


  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.faizan-rg123.id
    public_ip_address_id          = azurerm_public_ip.faizan-rg123.id
  }
}

resource "azurerm_network_interface_security_group_association" "faizan-rg123" {
  network_interface_id      = azurerm_network_interface.faizan-rg123.id
  network_security_group_id = azurerm_network_security_group.faizan-rg123.id
}

resource "azurerm_linux_virtual_machine" "faizan-rg123" {
  name                = "faizan-strapi-machine"
  resource_group_name = azurerm_resource_group.faizan-rg123.name
  location            = azurerm_resource_group.faizan-rg123.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "Password@1234"
  disable_password_authentication = false
  depends_on          = [azurerm_public_ip.faizan-rg123]

  network_interface_ids = [
    azurerm_network_interface.faizan-rg123.id,
  ]


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
 
   provisioner "remote-exec" {
     inline = [
        "set -x",
        "sudo apt-get update",
        "sudo apt-get install -y nodejs npm",
        "sudo npm install -g strapi@alpha",
        "strapi new myproject  --quickstart",
        "cd myproject",
        "npm install --force",
        "strapi build",
        "strapi start",
         #"sudo apt install nodejs",
      #  "sudo apt-get install -y nodejs",
       # "curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -",
       # "sudo apt-get install -y nodejs",
     #   "sudo apt install mongodb -y",
    #    "sudo systemctl start mongodb",
     #   "sudo systemctl enable mongodb",
       # "sudo npm install strapi@alpha -g",
      #  "sudo npm install pm2 -g -y",
      #  "cd ~",
    #    "sudo apt install mongodb -y",
       # "sudo strapi new myproject --quickstart",
       # "sudo cd myproject",
     #   "sudo npm install --production",
    #    "sudo strapi build",
    #    "sudo strapi start",
      ]
     }
     connection {
      type     = "ssh"
      user     = "adminuser"
      password = "Password@12#"
      host     = azurerm_public_ip.faizan-rg123.ip_address
    } 
}




