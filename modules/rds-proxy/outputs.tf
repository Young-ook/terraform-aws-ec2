### output variables

output "proxy" {
  description = "RDS proxy"
  value       = aws_db_proxy.proxy
}

output "endpoint" {
  description = "RDS proxy endpoint"
  value       = aws_db_proxy.proxy.endpoint
}
