lb_config = {
  lb_count      = 1
  eip_bandwidth = 1000
  lb_algorithm  = "ROUND_ROBIN"
  lb_protocol   = "TCP"
  lb_members    = module.cce.node_private_ips
}

## [Shared LB config]

#shared_lb_config = {
#  lb_count      = 1
#  eip_bandwidth = 1000
#  lb_method     = "ROUND_ROBIN"
#  lb_protocol   = "TCP"
#  #lb_members    = module.cce.node_private_ips
#  #default_pool_id = module.elb.default_pool_id
#}

ingress_nodeport = 31709