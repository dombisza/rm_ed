variable "prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "wafd_config" {
  type = object({
    wafd_count = number
  })
  default = {
    wafd_count = null
  }
}