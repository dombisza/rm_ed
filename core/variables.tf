variable "ak_sk_security_token" {
  type        = string
  description = "Security Token for temporary AK/SK"
}
variable "domain_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "owner" {
  type = string
}

variable "stage" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-de"
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
    lb_count      = 3
    eip_bandwidth = 100
    lb_algorithm  = "ROUND_ROBIN"
    lb_protocol   = "TCP"
    lb_members    = []
  }
  description = "LB configurational parameters"
}

