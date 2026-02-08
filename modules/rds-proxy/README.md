# Amazon RDS Proxy
By using [Amazon RDS Proxy](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html), you can allow your applications to pool and share database connections to improve their ability to scale. RDS Proxy makes applications more resilient to database failures by automatically connecting to a standby DB instance while preserving application connections. By using RDS Proxy, you can also enforce AWS Identity and Access Management (IAM) authentication for databases, and securely store credentials in AWS Secrets Manager.

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
  subnets = values(module.vpc.subnets["private"])
}

module "proxy" {
  source     = "Young-ook/ec2/aws//modules/rds-proxy"
  subnets    = values(module.vpc.subnets["private"])
  proxy_config = {
    cluster_id = module.rds.cluster.id
  }
  auth_config = {
    user_name     = module.rds.user.name
    user_password = module.rds.user.password
  }
}
```

Run terraform:
```
terraform init
terraform apply
```
