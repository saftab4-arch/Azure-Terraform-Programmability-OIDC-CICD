locals {
  name_prefix = "${lower(var.environment)}-lab4"
  vm_size     = var.environment == "prod" ? "Standard_D2s_v5" : "Standard_B1s"

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Terraform-Lab4"
  }
}
