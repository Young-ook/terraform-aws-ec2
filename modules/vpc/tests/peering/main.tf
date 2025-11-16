terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

locals {
  vpcs = [
    {
      name       = "vpc1"
      azs        = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
      cidr       = "10.8.0.0/16"
      single_ngw = false
    },
    {
      name       = "vpc2"
      azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
      cidr       = "10.9.0.0/16"
      single_ngw = true
    },
  ]
}

module "main" {
  source   = "../.."
  for_each = { for vpc in local.vpcs : vpc.name => vpc }
  vpc_config = {
    azs         = each.value["azs"]
    cidr        = each.value["cidr"]
    subnet_type = "private"
    single_ngw  = each.value["single_ngw"]
  }
}

resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = module.main["vpc1"].vpc.id
  vpc_id      = module.main["vpc2"].vpc.id
  auto_accept = true
}

resource "aws_route" "tovpc2" {
  for_each                  = module.main["vpc1"].route_tables["private"]
  route_table_id            = each.value
  destination_cidr_block    = module.main["vpc2"].vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "tovpc1" {
  for_each                  = module.main["vpc2"].route_tables["private"]
  route_table_id            = each.value
  destination_cidr_block    = module.main["vpc1"].vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
