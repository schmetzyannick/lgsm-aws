variable "region" {
  description = "The AWS region to deploy the Game Server VM"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "The instance type"
  type        = string
  default     = "t2.micro"
}

variable "spot" {
  description = "Whether to use spot instances"
  type        = bool
  default     = false
}

variable "vm-name" {
  description = "The name of the VM"
  type        = string
  default     = "GameServer"
}
