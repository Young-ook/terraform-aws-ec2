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
