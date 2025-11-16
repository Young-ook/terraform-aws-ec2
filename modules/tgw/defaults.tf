### default values

module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_tgw_config = {
    amazon_side_asn                 = "64512"
    default_route_table_association = true
    default_route_table_propagation = true
    auto_accept_shared_attachments  = false
    vpn_ecmp_support                = true
    dns_support                     = true
    ipv6_support                    = false
    appliance_mode_support          = false
  }
}
