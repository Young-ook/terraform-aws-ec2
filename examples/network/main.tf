### VPC blueprint

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### network/isolated
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.7"
  tags    = merge(var.tags, { topology = "aws" })
  vpc_config = {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "isolated"
  }
  vpce_config = [
    {
      service             = "ec2messages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssmmessages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssm"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "notebook"
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
      service             = "sts"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service = "s3"
      type    = "Gateway"
    },
    {
      service = "dynamodb"
      type    = "Gateway"
    },
  ]
}

### network/controller
module "corp" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.7"
  tags    = merge(var.tags, { topology = "corp" })
  vpc_config = {
    azs         = var.azs
    cidr        = "10.20.0.0/16"
    subnet_type = "isolated"
    single_ngw  = true
  }
  vpce_config = [
    {
      service             = "ec2messages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssmmessages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssm"
      type                = "Interface"
      private_dns_enabled = true
    },
  ]
}


### network/transit
module "tgw" {
  depends_on = [module.vpc, module.corp]
  source     = "Young-ook/vpc/aws//modules/tgw"
  version    = "1.0.8"
  tags       = var.tags
  tgw_config = {}
  vpc_attachments = {
    vpc = {
      vpc          = module.vpc.vpc.id
      subnets      = values(module.vpc.subnets["private"])
      route_tables = values(module.vpc.route_tables["private"])
      routes = [
        {
          destination_cidr_block = "10.20.0.0/16"
        },
      ]
    }
    corp = {
      vpc          = module.corp.vpc.id
      subnets      = values(module.corp.subnets["private"])
      route_tables = values(module.corp.route_tables["private"])
      routes = [
        {
          destination_cidr_block = "10.10.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "10.10.10.10/32"
        }
      ]
    }
  }
}

### security/firewall
resource "aws_security_group" "icmp" {
  for_each = {
    workspace = {
      vpc = module.vpc.vpc.id
    }
    client = {
      vpc = module.corp.vpc.id
    }
  }
  name   = join("-", ["icmp", each.key])
  vpc_id = each.value["vpc"]
  tags   = var.tags

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### compute
module "vm" {
  depends_on = [aws_security_group.icmp]
  for_each = {
    workspace = {
      subnets = values(module.vpc.subnets["private"])
    }
    client = {
      subnets = values(module.corp.subnets["private"])
    }
  }
  source  = "Young-ook/ssm/aws"
  version = "1.0.6"
  tags    = var.tags
  subnets = each.value["subnets"]
  node_groups = [
    {
      name            = each.key
      max_size        = 1
      instance_type   = "t3.large"
      security_groups = [aws_security_group.icmp[each.key].id]
    },
  ]
}
