### input variables

### network
variable "vpc_config" {
  description = "A Virtual Private Cloud (VPC) configuration"
  default     = {}
}

variable "vpce_config" {
  description = "A Virtual Private Cloud (VPC) endpoints configuration"
  default     = []
}

variable "vgw_config" {
  description = "A Virtual Private Gateway (VGW) configuration"
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
