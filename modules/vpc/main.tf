## virtual private cloud

module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

## parameters
locals {
  cidr            = !local.default_vpc ? lookup(var.vpc_config, "cidr", local.default_vpc_config.cidr) : null
  azs             = !local.default_vpc ? lookup(var.vpc_config, "azs", local.default_vpc_config.azs) : null
  selected_az     = !local.default_vpc ? local.azs.0 : null
  single_ngw      = !local.default_vpc ? lookup(var.vpc_config, "single_ngw", local.default_vpc_config.single_ngw) : null
  subnet_type     = !local.default_vpc ? lookup(var.vpc_config, "subnet_type", local.default_vpc_config.subnet_type) : null
  amazon_side_asn = !local.default_vpc ? lookup(var.vgw_config, "amazon_side_asn", local.default_vgw_config.amazon_side_asn) : null
}

## feature
locals {
  default_vpc  = (var.vpc_config == null || var.vpc_config == {}) ? true : false
  isolated     = ("isolated" == local.subnet_type) ? true : false
  public       = ("public" == local.subnet_type) ? true : false
  private      = ("private" == local.subnet_type) ? true : false
  vpce_config  = (var.vpce_config == null || var.vpce_config == []) ? local.default_vpce_config : var.vpce_config
  vpce_enabled = length(local.vpce_config) > 0 ? true : false
  vgw_enabled  = lookup(var.vgw_config, "enable_vgw", local.default_vgw_config.enable_vgw)
}

## default vpc
data "aws_vpc" "default" {
  count   = local.default_vpc ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = local.default_vpc ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.0.id]
  }
}

data "aws_subnet" "default" {
  for_each = local.default_vpc ? toset(data.aws_subnets.default.0.ids) : toset([])
  id       = each.key
}

## custom vpc
resource "aws_vpc" "vpc" {
  count                = !local.default_vpc ? 1 : 0
  cidr_block           = local.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.default-tags,
    { Name = local.name },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

### private subnet
resource "aws_subnet" "private" {
  for_each          = !local.default_vpc && !local.public ? toset(local.azs) : toset([])
  vpc_id            = local.vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(local.cidr, 8, (index(local.azs, each.value) * 8) + 1)

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "private", each.value]) },
    { "kubernetes.io/role/internal-elb" = "1" },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private" {
  for_each = !local.default_vpc && !local.public ? (local.single_ngw ? toset([local.selected_az]) : toset(local.azs)) : toset([])
  vpc_id   = local.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "private", "rt"]) },
    var.tags,
  )
}

resource "aws_route_table_association" "private" {
  for_each       = !local.default_vpc && !local.public ? toset(local.azs) : toset([])
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = local.single_ngw ? aws_route_table.private[local.selected_az].id : aws_route_table.private[each.key].id
}

resource "aws_route" "ingw" {
  for_each               = !local.default_vpc && local.private ? (local.single_ngw ? toset([local.selected_az]) : toset(local.azs)) : toset([])
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ingw[each.value].id

  timeouts {
    create = "5m"
  }
}

# nat gateway
resource "aws_eip" "ingw" {
  for_each = !local.default_vpc && local.private ? (local.single_ngw ? toset([local.selected_az]) : toset(local.azs)) : toset([])
  tags     = merge(local.default-tags, var.tags, )
  domain   = "vpc"
}

resource "aws_nat_gateway" "ingw" {
  for_each      = !local.default_vpc && local.private ? (local.single_ngw ? toset([local.selected_az]) : toset(local.azs)) : toset([])
  allocation_id = aws_eip.ingw[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "internet-facing", "ngw", each.key]) },
    var.tags,
  )
}

### public subnet
resource "aws_subnet" "public" {
  for_each                = !local.default_vpc && (local.public || local.private) ? toset(local.azs) : toset([])
  vpc_id                  = local.vpc.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(local.cidr, 8, (index(local.azs, each.value) * 8) + 2)
  map_public_ip_on_launch = true

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "public", each.value]) },
    { "kubernetes.io/role/elb" = "1" },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "public" {
  for_each = !local.default_vpc && (local.public || local.private) ? toset([local.selected_az]) : toset([])
  vpc_id   = local.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "public", "rt"]) },
    var.tags,
  )
}

resource "aws_route_table_association" "public" {
  for_each       = !local.default_vpc && (local.public || local.private) ? toset(local.azs) : toset([])
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[local.selected_az].id
}

resource "aws_route" "igw" {
  for_each               = !local.default_vpc && (local.public || local.private) ? toset([local.selected_az]) : toset([])
  route_table_id         = aws_route_table.public[local.selected_az].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[local.selected_az].id

  timeouts {
    create = "5m"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  for_each = !local.default_vpc && (local.public || local.private) ? toset([local.selected_az]) : toset([])
  vpc_id   = local.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "igw"]) },
    var.tags,
  )
}

# vpc endpoint
# security/firewall
resource "aws_security_group" "vpce" {
  count       = local.vpce_enabled ? 1 : 0
  name        = join("-", [local.name, "vpce"])
  description = format("security group for vpc endpoint of %s", local.name)
  vpc_id      = local.vpc.id
  tags        = merge(local.default-tags, { Name = join("-", [local.name, "vpce"]) }, var.tags)

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# For AWS services the service name is usually in the form com.amazonaws.<region>.<service>
# The SageMaker Notebook service is an exception to this rule, the service name is in the form
# aws.sagemaker.<region>.notebook.
data "aws_vpc_endpoint_service" "vpce" {
  for_each     = { for ep in local.vpce_config : ep.service => ep if local.vpce_enabled }
  service      = each.key == "notebook" ? null : each.key
  service_name = each.key == "notebook" ? format("aws.sagemaker.%s.notebook", module.aws.region.name) : null
  service_type = lookup(each.value, "type", "Gateway")
}

# How to use matchkey function (https://www.terraform.io/docs/language/functions/matchkeys.html)
# This matchkey function pick subnet IDs up where VPC endpoints are available
resource "aws_vpc_endpoint" "vpce" {
  for_each          = { for ep in local.vpce_config : ep.service => ep if local.vpce_enabled }
  service_name      = data.aws_vpc_endpoint_service.vpce[each.key].service_name
  vpc_endpoint_type = lookup(each.value, "type", "Gateway")
  vpc_id            = local.vpc.id
  route_table_ids = lookup(each.value, "type") == "Gateway" ? (
    !local.default_vpc ? (
      local.single_ngw ? [local.route_tables.private[local.selected_az]] : values(local.route_tables.private)
    ) : values(local.route_tables.public)
  ) : null
  subnet_ids = lookup(each.value, "type") == "Interface" ? matchkeys(
    values(local.vpce_subnets),
    keys(local.vpce_subnets),
    data.aws_vpc_endpoint_service.vpce[each.key].availability_zones
  ) : null
  security_group_ids  = lookup(each.value, "type") == "Interface" ? [aws_security_group.vpce.0.id] : null
  private_dns_enabled = lookup(each.value, "private_dns_enabled", false)
  policy              = lookup(each.value, "policy", null)

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "private", "vpce", each.key]) },
    var.tags,
  )
}

# vpn gateway
resource "aws_vpn_gateway" "vgw" {
  for_each          = local.vgw_enabled ? toset([local.selected_az]) : toset([])
  vpc_id            = local.vpc.id
  amazon_side_asn   = local.amazon_side_asn
  availability_zone = local.selected_az

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "vgw"]) },
    var.tags,
  )
}

resource "aws_vpn_gateway_route_propagation" "public" {
  for_each       = (local.default_vpc || local.public || local.private) && local.vgw_enabled ? toset(local.azs) : toset([])
  vpn_gateway_id = aws_vpn_gateway.vgw[local.selected_az].id
  route_table_id = local.default_vpc ? local.route_tables.public.main : local.route_tables.public[local.selected_az]
}

resource "aws_vpn_gateway_route_propagation" "private" {
  for_each       = !local.default_vpc && !local.public && local.vgw_enabled ? toset(local.azs) : toset([])
  vpn_gateway_id = aws_vpn_gateway.vgw[local.selected_az].id
  route_table_id = local.single_ngw ? local.route_tables.private[local.selected_az] : local.route_tables.private[each.key]
}
