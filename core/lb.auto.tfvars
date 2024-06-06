lb_config = {
  lb_count      = 1
  eip_bandwidth = 1000
  lb_algorithm  = "ROUND_ROBIN"
  lb_protocol   = "TCP"
  lb_members    = []
}

ingress_node_count = 1
