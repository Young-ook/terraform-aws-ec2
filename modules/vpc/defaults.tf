### default values

locals {
  default_vpc_config = {
    cidr        = "10.0.0.0/16"
    azs         = ["us-east-1a", "us-east-1b", "us-east-1c"]
    subnet_type = "private" # allowed values : "isolated" | "public" | "private"
    single_ngw  = false
  }
  default_vgw_config = {
    enable_vgw      = false
    amazon_side_asn = "64512"
  }
  default_vpce_config = []
}
