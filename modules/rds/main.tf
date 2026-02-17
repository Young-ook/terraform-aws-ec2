### Amazon Aurora Cluster

### condition
locals {
  enabled           = (var.cluster != null ? ((length(var.cluster) > 0) ? true : false) : false)
  compatibility     = (local.enabled ? lookup(var.cluster, "engine", "aurora-mysql") : "aurora-mysql")
  default_cluster   = (local.compatibility == "aurora-mysql" ? local.default_mysql_cluster : local.default_postgresql_cluster)
  default_instances = (local.compatibility == "aurora-mysql" ? local.default_mysql_instances : local.default_postgresql_instances)
  password          = lookup(var.cluster, "password", random_password.password.result)
}

### security/password
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = ":@.,+-!="
}

### security/firewall
resource "aws_security_group" "db" {
  name        = local.name
  description = format("security group for %s", local.name)
  vpc_id      = var.vpc
  tags        = merge(local.default-tags, var.tags)

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
resource "aws_db_subnet_group" "db" {
  name       = local.name
  subnet_ids = var.subnets
  tags       = merge(local.default-tags, var.tags)
}

### database/parameters
resource "aws_rds_cluster_parameter_group" "db" {
  name   = local.name
  tags   = merge(local.default-tags, var.tags)
  family = lookup(var.cluster, "family", local.default_cluster.family)
  dynamic "parameter" {
    for_each = lookup(var.cluster, "cluster_parameters", local.default_cluster.cluster_parameters)
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "db" {
  for_each = { for key, val in var.instances : key => val }
  name     = join("-", [local.name, random_string.iid[each.key].result])
  tags     = merge(local.default-tags, var.tags)
  family   = lookup(var.cluster, "family", local.default_cluster.family)
  dynamic "parameter" {
    for_each = lookup(var.instances[each.key], "instance_parameters", local.default_instances.0.instance_parameters)
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

### database/cluster
resource "aws_rds_cluster" "db" {
  cluster_identifier                  = local.name
  engine                              = lookup(var.cluster, "engine", local.default_cluster.engine)
  engine_mode                         = lookup(var.cluster, "mode", local.default_cluster.mode)
  engine_version                      = lookup(var.cluster, "version", local.default_cluster.version)
  port                                = lookup(var.cluster, "port", local.default_cluster.port)
  skip_final_snapshot                 = lookup(var.cluster, "skip_final_snapshot", local.default_cluster.skip_final_snapshot)
  database_name                       = lookup(var.cluster, "database", local.default_cluster.database)
  master_username                     = lookup(var.cluster, "user", local.default_cluster.user)
  master_password                     = local.password
  iam_database_authentication_enabled = lookup(var.cluster, "iam_auth_enabled", local.default_cluster.iam_auth_enabled)
  snapshot_identifier                 = lookup(var.cluster, "snapshot_id", local.default_cluster.snapshot_id)
  backup_retention_period             = lookup(var.cluster, "backup_retention", local.default_cluster.backup_retention)
  db_subnet_group_name                = aws_db_subnet_group.db.name
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.db.name
  vpc_security_group_ids              = coalescelist([aws_security_group.db.id], [])
  tags                                = merge(local.default-tags, var.tags)

  dynamic "scaling_configuration" {
    for_each = (lookup(var.cluster, "scaling", null) == null ? [] : toset([lookup(var.cluster, "scaling")]))
    content {
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", 256)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", 2)
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", true)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", 300)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", "ForceApplyCapacityChange")
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = (lookup(var.cluster, "scaling_v2", null) == null ? [] : toset([lookup(var.cluster, "scaling_v2")]))
    content {
      max_capacity = lookup(serverlessv2_scaling_configuration.value, "max_capacity", 128.0)
      min_capacity = lookup(serverlessv2_scaling_configuration.value, "min_capacity", 0.5)
    }
  }

  lifecycle {
    ignore_changes        = [snapshot_identifier, master_password]
    create_before_destroy = true
  }
}

### database/instance
resource "aws_rds_cluster_instance" "db" {
  depends_on              = [aws_rds_cluster.db]
  for_each                = { for k, v in var.instances : k => v }
  identifier              = join("-", [local.name, random_string.iid[each.key].result])
  cluster_identifier      = aws_rds_cluster.db.id
  engine                  = lookup(var.cluster, "engine", local.default_cluster.engine)
  engine_version          = lookup(var.cluster, "version", local.default_cluster.version)
  instance_class          = lookup(each.value, "instance_type", local.default_instances.0.instance_type)
  db_parameter_group_name = aws_db_parameter_group.db[each.key].name
  db_subnet_group_name    = aws_db_subnet_group.db.name
  apply_immediately       = tobool(lookup(var.cluster, "apply_immediately", local.default_cluster.apply_immediately))
  tags                    = merge(local.default-tags, var.tags)
}
