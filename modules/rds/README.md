# Amazon Aurora
[Amazon Aurora](https://aws.amazon.com/rds/aurora/) is a MySQL and PostgreSQL-compatible relational database built for the cloud, that combines the performance and availability of traditional enterprise databases with the simplicity and cost-effectiveness of open source databases. This module will create an Amazon Aurora Cluster on AWS.

![rds-vs-aurora-architecture-comparison](../../images/rds-vs-aurora-architecture-comparison.png)

## Setup
### Prerequisites
This module requires *terraform*. If you don't have the terraform tool in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-ec2) of this repository and follow the installation instructions.

### Quickstart
```
module "vpc" {
  source  = "Young-ook/ec2/aws//modules/vpc"
  version = "1.0.8"
}

module "rds" {
  source  = "Young-ook/ec2/aws//modules/rds"
  vpc     = module.vpc.vpc.id
  subnets = values(module.vpc.subnets["public"])
  tags    = { env = "test" }
}
```

Run terraform:
```
terraform init
terraform apply
```

# Additional Resources

## Amazon RDS
- [How can I increase the binlog retention in my Aurora MySQL-Compatible DB cluster?](https://repost.aws/knowledge-center/aurora-mysql-increase-binlog-retention)
- [Is Amazon RDS for PostgreSQL or Amazon Aurora PostgreSQL a better choice for me?](https://aws.amazon.com/blogs/database/is-amazon-rds-for-postgresql-or-amazon-aurora-postgresql-a-better-choice-for-me/)
- [Introducing the Aurora Storage Engine](https://aws.amazon.com/ko/blogs/database/introducing-the-aurora-storage-engine/)
- [Improve application availability with the AWS JDBC Driver for Amazon Aurora MySQL](https://aws.amazon.com/ko/blogs/database/improve-application-availability-with-the-aws-jdbc-driver-for-amazon-aurora-mysql)
- [Amazon Aurora-MySQL Workshop](https://catalog.workshops.aws/awsauroramysql/en-US)
- [Modernizing the Amazon Database Infrastructure](https://d1.awsstatic.com/whitepapers/modernizing-amazon-database-infrastructure.pdf?dbd_how1)
- [How LogMeIn migrated a billion records online from Oracle to Amazon Aurora and achieved sub-millisecond response time](https://aws.amazon.com/blogs/modernizing-with-aws/how-logmein-migrated-a-billion-records-online-from-oracle-to-amazon-aurora-and-achieved-sub-millisecond-response-time/)
- [RDS Snapshot Export to S3 Pipeline](https://github.com/aws-samples/rds-snapshot-export-to-s3-pipeline)

