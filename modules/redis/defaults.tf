### default values

### aws partition and region (global, gov, china)
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_cluster = {
    engine_version             = "6.x"
    parameter_group_name       = "default.redis6.x.cluster.on"
    port                       = 6379
    automatic_failover_enabled = true
    multi_az_enabled           = true
    transit_encryption_enabled = true
    retension_days             = 7
    num_node_groups            = 3
    replicas_per_node_group    = 2
    node_type                  = "cache.t2.micro"
  }
}
