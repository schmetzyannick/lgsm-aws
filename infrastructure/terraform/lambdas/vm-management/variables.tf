variable "region" {
  description = "The AWS region to deploy the Game Server VM"
  type        = string
  default     = "eu-west-1"
}

variable "image_tag" {
  default = "0.0.1"
  description = "value of the image tag"
  type = string
}

variable "zone-name" {
  description = "The name of the Route53 zone."
  type        = string  
}

locals {
  api-url-name = "lgsm"
}