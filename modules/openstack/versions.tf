terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0, < 4.0.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.34.1, < 2.0.0"
    }
  }
  required_version = "~> 1.9"
}
