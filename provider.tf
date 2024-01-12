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
  access_key  = ""
  secret_key  = ""
  region      = "KR"
  site        = "public"
  support_vpc = true
}
