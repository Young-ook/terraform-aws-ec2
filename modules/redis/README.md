# Amazon ElastiCache for Redis
[Amazon ElastiCache for Redis](https://aws.amazon.com/elasticache/redis/) is a blazing fast in-memory data store that provides sub-millisecond latency to power internet-scale real-time applications. Built on open-source Redis and compatible with the Redis APIs, ElastiCache for Redis works with your Redis clients and uses the open Redis data format to store your data. Your self-managed Redis applications can work seamlessly with ElastiCache for Redis without any code changes. ElastiCache for Redis combines the speed, simplicity, and versatility of open-source Redis with manageability, security, and scalability from Amazon to power the most demanding real-time applications in Gaming, Ad-Tech, E-Commerce, Healthcare, Financial Services, and IoT.

## Setup
### Prerequisites
This module requires *terraform*. If you don't have the terraform tool in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-ec2) of this repository and follow the installation instructions.

### Quickstart
```
module "vpc" {
  source  = "Young-ook/ec2/aws//modules/vpc"
  version = "1.0.8"
}

module "redis" {
  source  = "Young-ook/ec2/aws//modules/redis"
  vpc     = module.vpc.vpc.id
  subnets = values(module.vpc.subnets["public"])
}
```

Run terraform:
```
terraform init
terraform apply
```

# Additional Resources
## Amazon ElastiCache for Redis
- [How to work with Cluster Mode on Amazon ElastiCache for Redis](https://aws.amazon.com/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/)
- [Monitoring best practices with Amazon ElastiCache for Redis using Amazon CloudWatch](https://aws.amazon.com/blogs/database/monitoring-best-practices-with-amazon-elasticache-for-redis-using-amazon-cloudwatch/)
- [Amazon ElastiCache Deep Dive](https://pages.awscloud.com/rs/112-TZM-766/images/Session%201%20-%20ElastiCache-DeepDive_v2_rev.pdf)
- [Serving Billions of Ads in Just 100 ms Using Amazon Elasticache for Redis](https://aws.amazon.com/ko/blogs/architecture/serving-billions-of-ads-with-amazon-elasticache-for-redis/)

## Redis
- [Understanding Redis replication](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/Replication.Redis.Groups.html)
