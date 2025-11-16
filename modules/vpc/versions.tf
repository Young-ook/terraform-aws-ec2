## requirements

terraform {
  # Terraform test is an experimental features introduced in Terraform CLI v0.15.0.
  # So, you'll need to upgrade to v0.15.0 or later to use terraform test.
  required_version = ">= 0.15"

  # The 'domain' parameter was migrated from a 'Computed' attribute to an input attribute in the aws_eip resource in version 5.0.0
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
