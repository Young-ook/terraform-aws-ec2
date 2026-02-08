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
    family            = "aurora-mysql8.0"
    version           = "8.0.mysql_aurora.3.02.1"
    mode              = "provisioned"
    scaling_v2 = {
      max_capacity = 64
      min_capacity = 4
    }
  }
  instances = [
    {
      instance_type = "db.serverless"
    },
  ]
}

resource "test_assertions" "max_capacity" {
  component = "max_capacity"

  check "max_capacity" {
    description = "max capacity"
    condition   = can(module.main.cluster.serverlessv2_scaling_configuration.max_capacity == 64.0)
  }
}
