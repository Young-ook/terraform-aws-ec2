terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  source = "../.."
}

resource "test_assertions" "is_default_vpc" {
  component = "default_vpc"

  check "default_vpc" {
    description = "check if it is a default vpc"
    condition   = module.main.vpc.default
  }
}
