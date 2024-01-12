// Terraform init variable
terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

// Provider
provider "ncloud" {
  access_key  = "vGwpKA6X9pNJ6EAb3gq8"
  secret_key  = "iLBzpHzDWSr0ZJU1oNhrIA3XhvfUpCsVcC5NxfFi"
  region      = "KR"
  site        = "public"
  support_vpc = true
}