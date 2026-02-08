### output variables

output "cluster" {
  description = "Redis cluster"
  value       = aws_elasticache_replication_group.redis
}

output "endpoint" {
  description = "The endpoints of Redis cluster"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "user" {
  description = "The primary user credential of the Redis cluster"
  sensitive   = true
  value = zipmap(
    ["password"],
    [local.password]
  )
}
