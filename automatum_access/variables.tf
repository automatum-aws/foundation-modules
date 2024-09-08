variable "read_access" {
  type        = bool
  description = "Read only access"
  default     = true
}

variable "write_access" {
  type        = bool
  description = "Gives Write access"
  default     = false
}

variable "managed_services" {
  type        = bool
  description = "For managed services customers"
  default     = false
}
