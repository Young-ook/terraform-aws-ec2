### Amazon ElastiCache for Redis

### condition
locals {
  password = lookup(var.cluster, "password", random_password.password.result)
}

### security/password
resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "!&#$^<>-"
}

### security/firewall
resource "aws_security_group" "redis" {
  name        = local.name
  description = format("security group for %s", local.name)
  tags        = merge(local.default-tags, var.tags)
  vpc_id      = var.vpc

  ingress {
    from_port   = lookup(var.cluster, "port", local.default_cluster["port"])
    to_port     = lookup(var.cluster, "port", local.default_cluster["port"])
    protocol    = "tcp"
    cidr_blocks = var.cidrs
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### network/subnets
resource "aws_elasticache_subnet_group" "redis" {
  name       = local.name
  tags       = merge(local.default-tags, var.tags)
  subnet_ids = var.subnets
}

### cache/cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = local.name
  description                = "Cluster mode enabled ElastiCache for Redis"
  tags                       = merge(local.default-tags, var.tags)
  engine                     = "redis"
  engine_version             = lookup(var.cluster, "engine_version", local.default_cluster["engine_version"])
  port                       = lookup(var.cluster, "port", local.default_cluster["port"])
  security_group_ids         = [aws_security_group.redis.id]
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  node_type                  = lookup(var.cluster, "node_type", local.default_cluster["node_type"])
  parameter_group_name       = lookup(var.cluster, "parameter_group_name", local.default_cluster["parameter_group_name"])
  num_node_groups            = lookup(var.cluster, "num_node_groups", local.default_cluster["num_node_groups"])
  replicas_per_node_group    = lookup(var.cluster, "replicas_per_node_group", local.default_cluster["replicas_per_node_group"])
  automatic_failover_enabled = lookup(var.cluster, "automatic_failover_enabled", local.default_cluster["automatic_failover_enabled"])
  multi_az_enabled           = lookup(var.cluster, "multi_az_enabled", local.default_cluster["multi_az_enabled"])
  transit_encryption_enabled = lookup(var.cluster, "transit_encryption_enabled", local.default_cluster["transit_encryption_enabled"])
  auth_token                 = local.password

  log_delivery_configuration {
    destination      = module.logs.log_group.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
}

### observability/logs
module "logs" {
  source  = "Young-ook/eventbridge/aws//modules/logs"
  version = "0.0.12"
  name    = local.name
  log_group = {
    namespace      = "/aws/elasticache"
    retension_days = lookup(var.cluster, "retension_days", local.default_cluster["retension_days"])
  }
}
