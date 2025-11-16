### elastic file system

### filesystem/volume
resource "aws_efs_file_system" "efs" {
  tags      = merge(local.default-tags, var.tags)
  encrypted = lookup(var.filesystem, "encrypted", local.default_efs.encrypted)
}

### security/firewall
resource "aws_security_group" "efs" {
  name        = format("%s", local.name)
  description = format("default security group for %s", local.name)
  vpc_id      = var.vpc
  tags        = merge(local.default-tags, var.tags)

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_mount_target" "efs" {
  for_each        = { for k, v in var.subnets : k => v }
  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.efs.id]
  subnet_id       = each.value
}

resource "aws_efs_access_point" "ap" {
  for_each       = { for k, v in var.access_points : k => v }
  tags           = merge(local.default-tags, var.tags, { Name = random_string.apid[each.key].result })
  file_system_id = aws_efs_file_system.efs.id

  ### directory on the Amazon EFS file system that the access point provides access to.
  root_directory {
    path = lookup(each.value, "path", local.default_access_point.path)
    creation_info {
      owner_uid   = lookup(each.value, "uid", local.default_access_point.acl.uid)
      owner_gid   = lookup(each.value, "gid", local.default_access_point.acl.gid)
      permissions = lookup(each.value, "permissions", local.default_access_point.acl.permissions)
    }
  }

  ### operating system user and group applied to all file system requests made using the access point.
  posix_user {
    uid = lookup(each.value, "uid", local.default_access_point.acl.uid)
    gid = lookup(each.value, "gid", local.default_access_point.acl.gid)
  }
}
