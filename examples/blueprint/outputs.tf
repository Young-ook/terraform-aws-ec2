output "ec2" {
  description = "The generated AWS EC2 autoscaling groups"
  value       = module.ec2.cluster.data_plane
}

output "ssm-doc" {
  description = "The generated AWS Systems Manager Documents"
  value = {
    diskfull = aws_ssm_document.diskfull.arn
    cwagent  = aws_ssm_document.cwagent.arn
    envoy    = aws_ssm_document.envoy.arn
  }
}

output "rds" {
  description = "Aurora cluster"
  value       = module.rds.cluster
  sensitive   = true
}

output "rds-proxy" {
  description = "RDS proxy"
  value       = module.rds-proxy.proxy
}
