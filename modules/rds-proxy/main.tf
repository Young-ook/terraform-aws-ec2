### Amazon RDS Proxy

### database/parameter
locals {
  security_groups     = var.security_groups == [] ? null : var.security_groups
  debug_logging       = lookup(var.proxy_config, "debug_logging", local.default_proxy_config.debug_logging)
  engine_family       = lookup(var.proxy_config, "engine_family", local.default_proxy_config.engine_family)
  idle_client_timeout = lookup(var.proxy_config, "idle_client_timeout", local.default_proxy_config.idle_client_timeout)
  require_tls         = lookup(var.proxy_config, "require_tls", local.default_proxy_config.require_tls)
  target_role         = lookup(var.proxy_config, "target_role", local.default_proxy_config.target_role)
  auth                = lookup(var.proxy_config, "auth", local.default_auth_config)
  cluster_id          = lookup(var.proxy_config, "cluster_id", null)
  db_id               = lookup(var.proxy_config, "db_id", null)
  user_name           = lookup(var.auth_config, "user_name")     # required
  user_password       = lookup(var.auth_config, "user_password") # required
}

### security/secret
module "vault" {
  source  = "Young-ook/passport/aws//modules/aws-secrets"
  version = "0.0.12"
  name    = join("-", [local.user_name, local.name])
  secret  = local.user_password
}

### security/policy
resource "aws_iam_role" "proxy" {
  name = local.name
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("rds.%s", module.aws.partition.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "get-secret" {
  role       = aws_iam_role.proxy.id
  policy_arn = module.vault.policy_arns.read
}

### database/proxy
resource "aws_db_proxy" "proxy" {
  name                   = local.name
  tags                   = merge(local.default-tags, var.tags)
  debug_logging          = local.debug_logging
  engine_family          = local.engine_family
  idle_client_timeout    = local.idle_client_timeout
  require_tls            = local.require_tls
  role_arn               = aws_iam_role.proxy.arn
  vpc_subnet_ids         = var.subnets
  vpc_security_group_ids = local.security_groups

  auth {
    description = lookup(local.auth, "description", null)
    auth_scheme = lookup(local.auth, "auth_scheme", null)
    secret_arn  = lookup(local.auth, "secret_arn", module.vault.secret.arn)
    iam_auth    = lookup(local.auth, "iam_auth", null)
  }
}

resource "aws_db_proxy_default_target_group" "proxy" {
  db_proxy_name = aws_db_proxy.proxy.name
  connection_pool_config {
    connection_borrow_timeout    = 120
    init_query                   = "SET x=1, y=2"
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

resource "aws_db_proxy_target" "proxy" {
  db_instance_identifier = local.db_id
  db_cluster_identifier  = local.cluster_id
  db_proxy_name          = aws_db_proxy.proxy.name
  target_group_name      = aws_db_proxy_default_target_group.proxy.name
}
