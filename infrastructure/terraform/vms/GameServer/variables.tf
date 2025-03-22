variable "region" {
  description = "The AWS region to deploy the Game Server VM"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "The instance type"
  type        = string
  default     = "t3.small"
}

variable "spot" {
  description = "Whether to use spot instances"
  type        = bool
  default     = false
}

variable "ports" {
  description = "A list of ports to open on the security group"
  type        = list(number)
  default     = [2456, 2457, 2458]
}

variable "vm-name" {
  description = "The name of the VM"
  type        = string
  default     = "GameServer"
}
