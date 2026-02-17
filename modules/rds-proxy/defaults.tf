### default values

### aws partition and region (global, gov, china)
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_proxy_config = {
    debug_logging       = false
    engine_family       = "MYSQL" # allowed values: MYSQL | POSTGRESQL
    idle_client_timeout = 1800
    require_tls         = true
    target_role         = "READ_WRITE" # allowed values: READ_WRITE | READ_ONLY
  }
  default_auth_config = {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
  }
}
