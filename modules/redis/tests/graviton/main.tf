terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "vpc" {
  source  = "Young-ook/ec2/aws//modules/vpc"
  version = "1.0.8"
}

module "main" {
  source  = "../.."
  vpc     = module.vpc.vpc.id
  subnets = values(module.vpc.subnets["public"])
  cluster = {
    password      = "supersuperSecr0et"
    instance_type = "cache.m6g.large"
  }
}

resource "test_assertions" "pet_name" {
  component = "pet_name"
  check "pet_name" {
    description = "default random pet name"
    condition   = can(length(regexall("^redis", module.main.cluster.id)) > 0)
  }
}

resource "test_assertions" "password" {
  component = "password"
  check "custom_password" {
    description = "custom password"
    condition   = module.main.user.password == "supersuperSecr0et" ? true : false
  }
}
