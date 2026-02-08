### output variables

output "cluster" {
  description = "Aurora cluster"
  value       = aws_rds_cluster.db
}

output "instances" {
  description = "The Aurora DB instances"
  value       = aws_rds_cluster_instance.db
}

output "endpoint" {
  description = "The endpoints of Aurora cluster"
  value = zipmap(
    ["writer", "reader"],
    [aws_rds_cluster.db.endpoint, aws_rds_cluster.db.reader_endpoint]
  )
}

output "user" {
  description = "The master user credential of the Aurora cluster"
  sensitive   = true
  value = zipmap(
    ["database", "name", "password"],
    [aws_rds_cluster.db.database_name, aws_rds_cluster.db.master_username, local.password]
  )
}
