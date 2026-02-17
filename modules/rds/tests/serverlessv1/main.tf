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
    apply_immediately = "false"
    engine            = "aurora-mysql"
    version           = "5.7.mysql_aurora.2.08.3"
    mode              = "serverless"
    scaling = {
      max_capacity = 128
      min_capacity = 4
    }
  }
  instances = []
}

resource "test_assertions" "max_capacity" {
  component = "max_capacity"

  check "max_capacity" {
    description = "max capacity"
    condition   = can(module.main.cluster.scaling_configuration.max_capacity == 128)
  }
}
