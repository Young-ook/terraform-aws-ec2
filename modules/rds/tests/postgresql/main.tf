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
    engine            = "aurora-postgresql"
    version           = "11.7"
    port              = "5432"
    user              = "yourid"
    database          = "yourdb"
    backup_retention  = "1"
    apply_immediately = "false"
  }
  instances = [
    {
      instance_type = "db.t3.medium"
    },
    {
      instance_type = "db.t3.medium"
    }
  ]
}

resource "test_assertions" "pet_name" {
  component = "pet_name"

  check "pet_name" {
    description = "default random pet name"
    condition   = can(length(regexall("^rds", module.main.cluster.name)) > 0)
  }
}
