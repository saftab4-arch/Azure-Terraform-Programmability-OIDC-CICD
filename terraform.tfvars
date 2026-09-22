resource_group_name = "rg-terraform-lab4"
location            = "eastus"
environment         = "dev"

subnets = {
  web = {
    address_prefix = "10.20.1.0/24"
    tier           = "frontend"
  }

  app = {
    address_prefix = "10.20.2.0/24"
    tier           = "application"
  }

  db = {
    address_prefix = "10.20.3.0/24"
    tier           = "database"
  }
}
