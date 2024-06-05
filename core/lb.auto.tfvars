lb_config = {
  lb_count      = 2
  eip_bandwidth = 1000
  lb_algorithm  = "ROUND_ROBIN"
  lb_protocol   = "TCP"
  lb_members    = []
}

shared_lb_config = {
  lb_count      = 1
  eip_bandwidth = 1000
  lb_method     = "ROUND_ROBIN"
  lb_protocol   = "TCP"
  #lb_members    = module.cce.node_private_ips
  shared_node_pool_ids = "18118372-a85b-4a46-bf42-2168b61020bc"
}