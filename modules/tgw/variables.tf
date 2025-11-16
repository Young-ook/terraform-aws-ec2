### input variables

### network
variable "tgw" {
  description = "A Transit Gateway (TGW) configuration"
  default     = {}
  validation {
    condition     = var.tgw != null
    error_message = "Make sure to define valid transit gateway configuration."
  }
}

variable "vpc_attachments" {
  description = "Map of VPC details to attach to Transit Gateway (TGW)"
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
