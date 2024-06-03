lb_config = {
  lb_count      = 1
  eip_bandwidth = 1000
  lb_algorithm  = "ROUND_ROBIN"
  lb_protocol   = "TCP"
  lb_members    = module.cce.node_private_ips
}

ingress_nodeport = 31914