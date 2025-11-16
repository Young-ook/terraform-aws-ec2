terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

locals {
  availability_zones = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c", "ap-northeast-2d"]
  subnet_types = [
    {
      name        = "isolated"
      subnet_type = "isolated"
      az_count    = 2
      single_ngw  = false
    },
    {
      name        = "private"
      subnet_type = "private"
      az_count    = 3
      single_ngw  = true
    },
    {
      name        = "public"
      subnet_type = "public"
      az_count    = 1
      single_ngw  = true
    }
  ]
}

module "main" {
  for_each = { for net in local.subnet_types : net.name => net }
  source   = "../.."
  vpc_config = {
    azs        = slice(local.availability_zones, 0, each.value["az_count"])
    cidr       = "10.9.0.0/16"
    single_ngw = each.value["single_ngw"]
  }
  vpce_config = (each.value["subnet_type"] == "isolated") ? [
    {
      service             = "s3"
      type                = "Interface"
      private_dns_enabled = false
    },
    {
      service             = "sagemaker.api"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "sagemaker.runtime"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "notebook"
      type                = "Interface"
      private_dns_enabled = true
    },
  ] : null
}
