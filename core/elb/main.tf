data "opentelekomcloud_lb_flavor_v3" "elb_dedicated_L4_flavor" {
  name = "L4_flavor.elb.s1.small"
}

resource "opentelekomcloud_lb_loadbalancer_v3" "node_lb" {
  count = var.lb_config.lb_count

  name             = "lb-${count.index + 1}"
  router_id        = var.vpc_id
  network_ids      = [var.subnet_id]
  subnet_id        = var.vpc_subnet
  l4_flavor        = data.opentelekomcloud_lb_flavor_v3.elb_dedicated_L4_flavor.id
  ip_target_enable = true

  availability_zones = ["eu-de-01"]

  public_ip {
    id = opentelekomcloud_vpc_eip_v1.lb_fip[count.index].id
  }

  depends_on = [
    opentelekomcloud_vpc_eip_v1.lb_fip
  ]
}

resource "opentelekomcloud_vpc_eip_v1" "lb_fip" {
  count = var.lb_config.lb_count

  bandwidth {
    name        = "${var.prefix}-node-bandwidth"
    size        = var.lb_config.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }

  publicip {
    type    = "5_bgp"
    #port_id = opentelekomcloud_lb_loadbalancer_v3.node_lb[count.index].vip_port_id
  }

  lifecycle {
    prevent_destroy = false # Releasing the EIP of the application is irreversible and will cause the application to be unreachable until new ip address completes DNS propagation.
  }
}

resource "opentelekomcloud_lb_listener_v3" "listener" {
  #count           = local.loadbalancer_count
  count           = var.lb_config.lb_count
  name            = "${var.prefix}-node-cce-listener"
  protocol        = "TCP"
  protocol_port   = 80
  #loadbalancer_id = var.node_lb_ids[count.index]
  loadbalancer_id = opentelekomcloud_lb_loadbalancer_v3.node_lb[count.index].id

  lifecycle {
    create_before_destroy = true
  }
}

resource "opentelekomcloud_lb_pool_v3" "lb_node_pool" {
  count = var.lb_config.lb_count
  name  = "kubernetes-nodeport-${count.index + 1}"

  loadbalancer_id = opentelekomcloud_lb_loadbalancer_v3.node_lb[count.index].id
  listener_id     = opentelekomcloud_lb_listener_v3.listener[count.index].id
  lb_algorithm    = var.lb_config.lb_algorithm
  protocol        = var.lb_config.lb_protocol
  description     = "Pool of application nodes"
}

resource "opentelekomcloud_lb_member_v3" "member" {
  count = length(var.lb_config.lb_members) * var.lb_config.lb_count

  pool_id       = opentelekomcloud_lb_pool_v3.lb_node_pool[count.index % var.lb_config.lb_count].id
  address       = var.lb_config.lb_members[floor(count.index / var.lb_config.lb_count)]
  protocol_port = var.nodeport
  subnet_id = var.vpc_subnet
}

