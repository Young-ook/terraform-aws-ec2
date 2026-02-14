tags = { example = "ec2_blueprint" }
aurora_cluster = {
  engine            = "aurora-mysql"
  family            = "aurora-mysql8.0"
  version           = "8.0.mysql_aurora.3.01.0"
  port              = "3306"
  user              = "yourid"
  database          = "yourdb"
  backup_retention  = "5"
  apply_immediately = "false"
  cluster_parameters = {
    character_set_server = "utf8"
    character_set_client = "utf8"
  }
}
aurora_instances = [
  {
    instance_type = "db.r6g.large"
    instance_parameters = {
      autocommit = 0
    }
  },
  {
    instance_type = "db.r6g.large"
  },
]
