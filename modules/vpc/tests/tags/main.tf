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

resource "aws_ec2_tag" "tags" {
  for_each    = toset(values(module.main.subnets["public"]))
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = "eks-mockup"
}

resource "test_assertions" "is_default_vpc" {
  component = "default_vpc"

  check "default_vpc" {
    description = "check if it is a default vpc"
    condition   = module.main.vpc.default
  }
}

resource "test_assertions" "subnet_tag" {
  component = "subnet_tag"

  check "subnet_tag" {
    description = "check if an additional subnet tag is attached properly"
    condition   = element(values(aws_ec2_tag.tags), 0)["value"] == "eks-mockup"
  }
}
