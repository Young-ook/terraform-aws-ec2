### output variables

locals {
  vpc = local.default_vpc ? data.aws_vpc.default.0 : aws_vpc.vpc.0
  route_tables = (local.default_vpc ?
    {
      public = { main = data.aws_vpc.default.0.main_route_table_id }
    } :
    {
      public  = { for k, v in aws_route_table.public : k => v.id }
      private = { for k, v in aws_route_table.private : k => v.id }
    }
  )
  subnets = (local.default_vpc ?
    {
      public = { for net in data.aws_subnet.default : net.availability_zone => net.id }
    } :
    {
      public  = { for k, v in aws_subnet.public : k => v.id }
      private = { for k, v in aws_subnet.private : k => v.id }
    }
  )
  vpce_subnets = local.default_vpc || local.public ? local.subnets.public : local.subnets.private
}

output "vpc" {
  description = "Attributes of the Virtual Private Cloud (VPC)"
  value       = local.vpc
}

output "subnets" {
  description = "A list of subnet IDs in the VPC"
  value       = local.subnets
}

output "route_tables" {
  description = "A list of route table IDs in the VPC"
  value       = local.route_tables
}

output "vpce" {
  description = "Attributes of the VPC endpoints"
  value       = aws_vpc_endpoint.vpce
}

output "vgw" {
  description = "Attributes of Virtual Private Gateway (VGW)"
  value       = aws_vpn_gateway.vgw
}
