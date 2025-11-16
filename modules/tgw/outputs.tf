### output variables

output "tgw" {
  description = "Attributes of Transit Gateway (TGW)"
  value       = aws_ec2_transit_gateway.tgw
}

output "vpc_attachments" {
  description = "Attributes of VPC attachments"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpcs
}

output "vpc_routes" {
  description = "Attributes of VPC route to Transit Gateway (TGW)"
  value       = aws_route.vpcs
}
