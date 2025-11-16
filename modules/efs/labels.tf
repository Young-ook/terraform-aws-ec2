### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "3.0.0"
  name    = var.name == null || var.name == "" ? "efs" : var.name
  petname = var.name == null || var.name == "" ? true : false
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}

### access point id
resource "random_string" "apid" {
  for_each = { for k, v in var.access_points : k => v }
  length   = 5
  upper    = false
  lower    = true
  numeric  = false
  special  = false
}
