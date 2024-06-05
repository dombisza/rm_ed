lb_config = {
  lb_count      = 3
  eip_bandwidth = 1000
  lb_algorithm  = "ROUND_ROBIN"
  lb_protocol   = "TCP"
  lb_members    = []
}
