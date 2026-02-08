### input variables

### network
variable "subnets" {
  description = "The subnet IDs for rds"
  type        = list(string)
  default     = []
}

### security
variable "security_groups" {
  description = "The security group IDs for rds"
  type        = list(string)
  default     = []
}

variable "auth_config" {
  description = "Authentication configuration"
  default     = {}
}

### db proxy
variable "proxy_config" {
  description = "RDS proxy configuration"
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
