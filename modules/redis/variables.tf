### input variables

### network
variable "vpc" {
  description = "The VPC ID"
  type        = string
}

variable "cidrs" {
  description = "The list of CIDR blocks to allow ingress traffics"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "The subnet IDs"
  type        = list(string)
  default     = []
}

### redis cluster
variable "cluster" {
  description = "ElastiCache for Redis cluster definition"
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
