#variable "prefix" {}
#variable "vpc_id" {}
#variable "subnet_id" {}
#variable "lb_count" {
#  default = 2
#}
#variable "lb_members" {}
#variable "vpc_subnet" {}
#variable "ingress_nodeport" {}


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

variable "ingress_node_count" {
  default = 3
}

variable "ingress_nodeport" {
  type = number
  description = "Nodeport to where the LB connects"
}

variable "lb_config" {
  type = object({
    lb_count      = number
    eip_bandwidth = number 
    lb_algorithm  = string
    lb_protocol   = string 
    lb_members    = list(string)
  })
  default = {
    lb_count      = 2
    eip_bandwidth = 1000
    lb_algorithm  = "ROUND_ROBIN"
    lb_protocol   = "TCP"
    lb_members    = []
  }
  description = "LB configurational parameters"
}

variable "disable_health_check" {
  type = bool
  default = false
}

## [Shared LB related variables]

#variable "shared_lb_config" {
#  type = object({
#    lb_count      = number
#    eip_bandwidth = number 
#    lb_method     = string
#    lb_protocol   = string 
#    shared_node_pool_ids = string
#  })
#  default = {
#    lb_count      = 2
#    eip_bandwidth = 1000
#    lb_method     = "ROUND_ROBIN"
#    lb_protocol   = "TCP"
#    shared_node_pool_ids = "18118372-a85b-4a46-bf42-2168b61020bc"
#  }
#  description = "Shared LB configurational parameters"
#}

#variable "shared_node_pool_ids" {
#  type        = list(string)
#}