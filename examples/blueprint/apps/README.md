[[English](README.md)] [[한국어](README.ko.md)]

# Applications
## EC2 Auto Scaling Warm Pools
A warm pool is a pool of pre-initialized EC2 instances that sits alongside the Auto Scaling group. Whenever your application needs to scale out, the Auto Scaling group can draw on the warm pool to meet its new desired capacity. A warm pool gives you the ability to decrease latency for your applications that have exceptionally long boot times, for example, because instances need to write massive amounts of data to disk. With warm pools, you no longer have to over-provision your Auto Scaling groups to manage latency in order to improve application performance. For more information and example configurations, see [Warm pools for Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html) in the Amazon EC2 Auto Scaling User Guide.

### Warm pool instance lifecycle
Instances in the warm pool maintain their own independent lifecycle to help you create the appropriate lifecycle actions for each transition. An Amazon EC2 instance transitions through different states from the moment it launches through to its termination. You can create lifecycle hooks to act on these event states, when an instance has transitioned from one state to another one.

The following diagram shows the transition between each state:

![aws-asg-wp-lifecycle](../../../images/aws-asg-wp-lifecycle.png)

### Verify
After terraform apply, you will see an instance in the warm pools. That instance will be launched to run the user-data script for application initialization when it is registered with the warm-pool. In this example, the user-data script waits for a while to simulate a long working time.

![aws-asg-wp-init-instance](../../../images/aws-asg-wp-init-instance.png)

After initialization, the instance state changes to 'Stopped' for waiting.

![aws-asg-wp-stopped](../../../images/aws-asg-wp-stopped.png)

To check the elpased time to initial configuration of the instance, run this script:
```
bash elapsedtime.sh
```
The output of this command shows the duration of the instance launch.
```
Launching a new EC2 instance into warm pool: i-0180961b460339ed3 Duration: 215s
```

### Launch a new instance from warm pool
Modify the *desired_capacity* value of *warmpools* in *node_groups* in [main.tf](https://github.com/Young-ook/terraform-aws-ssm/tree/main/examples/blueprint/main.tf) file to 1 to scale out the current autoscaling group. After terraform configuration file update, run again terraform apply.
```
terraform apply
```
The output of the change plan will be displayed. Check it, and enter *yes* to confirm. After a few minutes, run the script below to see the history of Autoscaling group activity and the elapsed time of each operation.
```
bash elapsedtime.sh
```
The output of this command shows the duration of the instance launch.
```
Launching a new EC2 instance from warm pool: i-0180961b460339ed3 Duration: 19s
Launching a new EC2 instance into warm pool: i-0180961b460339ed3 Duration: 215s
```

![aws-asg-activity-history](../../../images/aws-asg-activity-history.png)

## AWS Systems Manager Documents
### Run command
You can use Run Command, a capability of AWS Systems Manager, from the console to configure instances without having to log in to each instance.

**To send a command using Run Command**

1. Open the AWS Systems Manager console at https://console.aws.amazon.com/systems-manager/.
1. In the navigation pane, choose Run Command. Or if the AWS Systems Manager home page opens first, choose the menu icon (stacked three bars) to open the navigation pane, and then choose *Run Command*.
1. Choose *Run command*.
1. In the Command document list, choose a Systems Manager document.
1. In the Command parameters section, specify values for required parameters.
1. In the Targets section, identify the instances on which you want to run this operation by specifying tags, selecting instances manually, or specifying a resource group.
1. For Other parameters:
    * For Comment, enter information about this command.
    * For Timeout (seconds), specify the number of seconds for the system to wait before failing the overall command execution.
1. For Rate control:
    * For Concurrency, specify either a number or a percentage of instances on which to run the command at the same time.
1. (Optional) For Output options, to save the command output to a file, select the Write command output to an S3 bucket box. Enter the bucket and prefix (folder) names in the boxes.
1. Choose *Run*.

## Load Test (Taurus by BlazeMeter)
[Taurus](https://gettaurus.org/) is a integrated load testing tool that hides the complexity of performance and functional tests with an automation-friendly convenience wrapper. Taurus relies on JMeter, Gatling, Locust.io, and Selenium WebDriver as its underlying tools.

### Test Scenarios
You can define your test scenarios using YAML config file and Python script file. This is an example files:

test.yaml (testing environment and parameters)
```yaml
---
execution:
- executor: locust
  concurrency: 10
  ramp-up: 1m
  iterations: 1000
  scenario: hellotest

scenarios:
  hellotest:
    default-address: ${target}
    script: test.py
```

test.py (test cases)
```python
from locust import HttpUser, TaskSet, task, between

class WebsiteTasks(TaskSet):
    @task
    def index(self):
        self.client.get("/")

    @task
    def about(self):
        self.client.get("/status")

class WebsiteUser(HttpUser):
    tasks = [WebsiteTasks]
    wait_time = between(0.100, 1.500)
```

Also, you can run simple test without python script with Locust executor if your test is one of the supported cases:
 - request methods GET/POST
 - headers and body for requests
 - set timeout/think-time on both scenario/request levels
 - assertions (for body and http-code)

test.yaml
```yaml
---
execution:
- executor: locust
  concurrency: 10
  ramp-up: 1m
  iterations: 1000
  scenario: hellotest

scenarios:
  request_example:
    timeout: 10  #  global scenario timeout for connecting, receiving results, 30 seconds by default
    think-time: 1s500ms  # global scenario delay between each request
    default-address: ${target}  # specify a base address, so you can use short urls in requests
    keepalive: true  # flag to use HTTP keep-alive for connections, default is true
    requests:
    - url: /
      method: get
      headers:
        var1: val1
      body: 'body content'
      assert:
      - contains:
        - body  # list of search patterns
        - content
        subject: body # subject for check
        regexp: false  # treat string as regular expression, true by default
        not: false  # inverse assertion condition
```

### Connect
To access the EC2 instance, go to the EC2 service on the AWS Management Conosol. Find and select the instance you want and click *Connect* button on top of the window. After then you will see three tabs EC2 Instance Connect, Session Manager, SSH client. Select Session Manager tab and follow the instruction on the screen.

### Run Taurus
You will see Taurus load testing tool in your instance, and you can run load test using it. If you need to know how to use it, run `bzt` command with `-h` option:

```
bzt -h
Usage: bzt [options] [configs] [-aliases]

BlazeMeter Taurus Tool v1.16.18, the configuration-driven test running engine

Options:
  -h, --help            show this help message and exit
  -l LOG, --log=LOG     Log file location
  -o OPTION, --option=OPTION
                        Override option in config
  -q, --quiet           Only errors and warnings printed to console
  -v, --verbose         Prints all logging messages to console
  -n, --no-system-configs
                        Skip system and user config files
```

![aws-ec2-bzt-dashboard](../../../images/aws-ec2-bzt-dashboard.png)
![aws-ec2-bzt-log](../../../images/aws-ec2-bzt-log.png)

## Sysbench
### Connect to EC2
Move to the EC2 service page on the AWS Management Conosol and select Instances button on the left side menu. Find an instance that you launched. Select the instance and click 'Connect' button on top of the window. After then you will see three tabs EC2 Instance Connect, Session Manager, SSH client. Select Session Manager tab and follow the instruction on the screen.

### Install sysbench
Run below command to install sysbench and database clients on your EC2 workspace:
```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install mysql postgresql sysbench
```

Make sure the installation is complete. If the output looks like `sysbench 1.0.20`, then sysbench is installed properly.
```
sysbench --version
```

# Additional Resources
- [Distributed Load Testing on AWS](https://github.com/aws-solutions/distributed-load-testing-on-aws)
- [Performance Test: Amazon Aurora-MySQL on AWS Graviton2](https://github.com/gnosia93/oracle-to-postgres/blob/main/appendix/mysql-aurora-graviton2.md)
- [Performance Test: Amazon Aurora-PostgreSQL on AWS Graviton2](https://github.com/gnosia93/oracle-to-postgres/blob/main/appendix/postgres-aurora-graviton2.md)

