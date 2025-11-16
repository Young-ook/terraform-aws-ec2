# AWS Transit Gateway
[AWS TGW (Transit Gateway)](https://aws.amazon.com/transit-gateway/) is a service that connects VPCs and on-premises networks through a central hub. This simplifies your network and puts an end to complex peering relationships. It acts as a cloud router – each new connection is only made once.

As you expand globally, inter-Region peering connects AWS Transit Gateways together using the AWS global network. Your data is automatically encrypted, and never travels over the public internet. And, because of its central position, AWS Transit Gateway Network Manager has a unique view over your entire network, even connecting to Software-Defined Wide Area Network (SD-WAN) devices.

## Quickstart
### Setup
```
module "vpc1" {
  source  = "Young-ook/vpc/aws"
  vpc_config = {
    azs         = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2d"]
    cidr        = "10.10.0.0/16"
    subnet_type = "isolated"
  }
}

module "vpc2" {
  source  = "Young-ook/vpc/aws"
  vpc_config = {
    azs         = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2d"]
    cidr        = "10.20.0.0/16"
    subnet_type = "isolated"
  }
}

module "tgw" {
  source = "Young-ook/vpc/aws//modules/tgw"
  vpc_attachments = {
    vpc = {
      vpc          = module.vpc1.vpc.id
      subnets      = values(module.vpc1.subnets["private"])
      route_tables = values(module.vpc1.route_tables["private"])
      routes = [
        {
          destination_cidr_block = "10.20.0.0/16"
        },
      ]
    }
    corp = {
      vpc          = module.vpc2.vpc.id
      subnets      = values(module.vpc2.subnets["private"])
      route_tables = values(module.vpc2.route_tables["private"])
      routes = [
        {
          destination_cidr_block = "10.10.0.0/16"
        },
      ]
    }
  }
}
```

Run terraform:
```
terraform init
terraform apply
```

# Additional Resources
## AWS Transit Gateway
- [AWS Transit Gateway Routing Lab](https://github.com/aws-samples/aws-transit-gateway-routing-lab)
