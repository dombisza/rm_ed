#variable "prefix" {}
#variable "vpc_id" {}
#variable "subnet_id" {}
#variable "lb_count" {
#  default = 2
#}
#variable "lb_members" {}
#variable "vpc_subnet" {}
#variable "nodeport" {}


variable "prefix" {
  type        = string
  description = "Prefix for all OTC resource names"
}

variable "vpc_id" {
  type        = string
  description = "Previously created vpc id."
}

variable "vpc_subnet" {
  type        = string
  description = "Previously created  subnet id."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to which the LoadBalancer belongs"
}

variable "nodeport" {
  type = number
  description = "Nodeport to where the LB connects"
}

variable "lb_config" {
  type = object({
    lb_count      = number
    eip_bandwidth = number 
    lb_algorithm  = string
    lb_protocol   = string 
    lb_members    = string
  })
  description = "LB configurational parameters"
}

#variable "disable_health_check" {
#  type    = bool
#  default = false
#}