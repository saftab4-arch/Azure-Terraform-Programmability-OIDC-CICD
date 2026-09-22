variable "resource_group_name" {
  description = "Name of the Lab 4 resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "subnets" {
  description = "Subnet configuration"

  type = map(object({
    address_prefix = string
    tier           = string
  }))

}


