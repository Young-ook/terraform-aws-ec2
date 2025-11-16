### transit gateway

### parameters
locals {
  amazon_side_asn                  = lookup(var.tgw, "amazon_side_asn", local.default_tgw_config.amazon_side_asn)
  default_route_table_assocication = lookup(var.tgw, "enable_default_route_table_association", local.default_tgw_config.default_route_table_association)
  default_route_table_propagation  = lookup(var.tgw, "enable_default_route_table_propagation", local.default_tgw_config.default_route_table_propagation)
  auto_accept_shared_attachments   = lookup(var.tgw, "enable_auto_accept_shared_attachments", local.default_tgw_config.auto_accept_shared_attachments)
  vpn_ecmp_support                 = lookup(var.tgw, "enable_vpn_ecmp_support", local.default_tgw_config.vpn_ecmp_support)
  dns_support                      = lookup(var.tgw, "enable_dns_support", local.default_tgw_config.dns_support)
}

### transit gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = local.name
  tags                            = merge(local.default-tags, var.tags)
  default_route_table_association = local.default_route_table_assocication ? "enable" : "disable"
  default_route_table_propagation = local.default_route_table_propagation ? "enable" : "disable"
  auto_accept_shared_attachments  = local.auto_accept_shared_attachments ? "enable" : "disable"
  vpn_ecmp_support                = local.vpn_ecmp_support ? "enable" : "disable"
  dns_support                     = local.dns_support ? "enable" : "disable"
  amazon_side_asn                 = local.amazon_side_asn

  lifecycle {
    create_before_destroy = true
  }
}

### network/attachment
locals {
  vpc_attachments_with_routes = [
    for e in chunklist(
      flatten([
        for k, v in var.vpc_attachments : setproduct([{ vpc = k }], v["routes"]) if length(lookup(v, "routes", {})) > 0
      ]),
    2) : merge(e[0], e[1])
  ]

  vpc_attachments_without_default_route_table_association = {
    for k, v in var.vpc_attachments : k => v if lookup(v, "transit_gateway_default_route_table_association", local.default_tgw_config.default_route_table_association) != true
  }

  vpc_attachments_without_default_route_table_propagation = {
    for k, v in var.vpc_attachments : k => v if lookup(v, "transit_gateway_default_route_table_propagation", local.default_tgw_config.default_route_table_propagation) != true
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpcs" {
  for_each                                        = var.vpc_attachments
  tags                                            = merge(local.default-tags, var.tags)
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = lookup(each.value, "vpc")
  subnet_ids                                      = lookup(each.value, "subnets")
  dns_support                                     = lookup(each.value, "dns_support", local.default_tgw_config.dns_support) ? "enable" : "disable"
  ipv6_support                                    = lookup(each.value, "ipv6_support", local.default_tgw_config.ipv6_support) ? "enable" : "disable"
  appliance_mode_support                          = lookup(each.value, "appliance_mode_support", local.default_tgw_config.appliance_mode_support) ? "enable" : "disable"
  transit_gateway_default_route_table_association = lookup(each.value, "transit_gateway_default_route_table_association", local.default_tgw_config.default_route_table_association)
  transit_gateway_default_route_table_propagation = lookup(each.value, "transit_gateway_default_route_table_propagation", local.default_tgw_config.default_route_table_propagation)
}

resource "aws_ec2_transit_gateway_route_table_association" "vpcs" {
  for_each                      = local.vpc_attachments_without_default_route_table_association
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpcs[each.key].id
  transit_gateway_route_table_id = coalesce(
    lookup(each.value, "transit_gateway_route_table_id", null),
    aws_ec2_transit_gateway_route_table.domain.id
  )
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpcs" {
  for_each                      = local.vpc_attachments_without_default_route_table_propagation
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpcs[each.key].id
  transit_gateway_route_table_id = coalesce(
    lookup(each.value, "transit_gateway_route_table_id", null),
    aws_ec2_transit_gateway_route_table.domain.id
  )
}

### network/route
resource "aws_ec2_transit_gateway_route_table" "domain" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags               = merge(local.default-tags, var.tags)
}

resource "aws_ec2_transit_gateway_route" "domain" {
  for_each                       = { for k, v in local.vpc_attachments_with_routes : k => v }
  destination_cidr_block         = each.value.destination_cidr_block
  blackhole                      = lookup(each.value, "blackhole", false)
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.domain.id
  transit_gateway_attachment_id  = tobool(lookup(each.value, "blackhole", false)) ? null : aws_ec2_transit_gateway_vpc_attachment.vpcs[each.value.vpc].id
}

resource "aws_route" "vpcs" {
  for_each = { for k, v in [
    for e in chunklist(flatten([
      for k, v in var.vpc_attachments : setproduct(try(v["route_tables"], []), [for r in try(v["routes"], []) : r.destination_cidr_block])
    ]), 2) : { rt = e[0], cidr = e[1] }
  ] : k => v }
  route_table_id         = each.value["rt"]
  destination_cidr_block = each.value["cidr"]
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
