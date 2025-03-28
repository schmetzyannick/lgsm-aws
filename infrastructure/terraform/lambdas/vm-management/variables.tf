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