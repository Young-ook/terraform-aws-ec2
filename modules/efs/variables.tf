### network
variable "vpc" {
  description = "VPC Id"
  type        = string
}

variable "subnets" {
  description = "Subnet Ids"
  type        = list(string)
}

variable "access_points" {
  description = "Access Points configuration"
  type        = any
  default     = []
}

### file system
variable "filesystem" {
  description = "EFS file system configuration"
  default     = {}
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
