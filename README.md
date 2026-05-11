[[English](README.md)] [[한국어](README.ko.md)]

# Amazon EC2 (Elastic Compute Cloud)
[Amazon EC2 (Elastic Compute Cloud)](https://aws.amazon.com/ec2) is secure and resizable compute capacity for virtually any workload. EC2 service offers the broadest and deepest compute platform, with over 1000 instances and choice of the latest processor, storage, networking, operating system, and purchase model to help you best match the needs of your workload.

## Examples
- [Amazon EC2 Blueprint](https://github.com/Young-ook/terraform-aws-ec2/tree/main/examples/blueprint)
- [Amazon VPC Network](https://github.com/Young-ook/terraform-aws-ec2/tree/main/examples/network)
- [AWS FIS Blueprint (Chaos Engineering)](https://github.com/Young-ook/terraform-aws-fis/blob/main/examples/blueprint)
- [AWS Identity and Access Management Blueprint](https://github.com/Young-ook/terraform-aws-passport/tree/main/examples/blueprint)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

After the installation is complete, you can check the aws cli version:
```
aws --version
aws-cli/2.5.8 Python/3.9.11 Darwin/21.4.0 exe/x86_64 prompt/off
```

### Terraform
Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

#### Install
This is the official guide for terraform binary installation. Please visit this [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) website and follow the instructions.

Or, you can manually get a specific version of terraform binary from the websiate. Move to the [Downloads](https://www.terraform.io/downloads.html) page and look for the appropriate package for your system. Download the selected zip archive package. Unzip and install terraform by navigating to a directory included in your system's `PATH`.

Or, you can use [tfenv](https://github.com/tfutils/tfenv) utility. It is very useful and easy solution to install and switch the multiple versions of terraform-cli.

First, install tfenv using brew.
```
brew install tfenv
```
Then, you can use tfenv in your workspace like below.
```
tfenv install <version>
tfenv use <version>
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
tfenv list
tfenv install latest
tfenv use <version>
```

### Setup
```
module "ec2" {
  source  = "Young-ook/ec2/aws"
  name    = "ssm"
  tags    = { env = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```

## Connect
Move to the EC2 service page on the AWS Management Conosol and select Instances button on the left side menu. Find an instance that you launched. Select the instance and click *Connect* button on top of the window. After then you will see three tabs EC2 Instance Connect, Session Manager, SSH client. Select Session Manager tab and follow the instruction on the screen.

![aws-fis-ec2-disk-stress](images/aws-fis-ec2-disk-stress.png)
