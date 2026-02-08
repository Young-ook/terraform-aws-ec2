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
}

resource "test_assertions" "pet_name" {
  component = "pet_name"

  check "pet_name" {
    description = "default random pet name"
    condition   = can(length(regexall("^rds", module.main.cluster.name)) > 0)
  }
}
