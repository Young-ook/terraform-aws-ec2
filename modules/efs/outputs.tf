### output variables

output "efs" {
  description = "Attributes of the generated efs"
  value       = aws_efs_file_system.efs
}

output "mnt" {
  description = "A list of mount target to access efs volume"
  value       = { for mnt in values(aws_efs_mount_target.efs) : mnt.availability_zone_name => mnt }
}

output "ap" {
  description = "Attributes of access point for efs volume"
  value       = aws_efs_access_point.ap
}

output "security_group" {
  description = "The attributes of security group for efs"
  value       = aws_security_group.efs
}
