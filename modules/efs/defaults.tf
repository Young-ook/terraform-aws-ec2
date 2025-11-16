### default values

locals {
  default_access_point = {
    path = "/"
    acl = {
      gid         = "1001"
      uid         = "1001"
      permissions = "750"
    }
  }
  default_efs = {
    encrypted = true
  }
}
