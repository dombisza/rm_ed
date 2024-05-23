data "opentelekomcloud_lb_flavor_v3" "elb_dedicated_L4_flavor" {
  name = "L4_flavor.elb.s1.small"
}

resource "opentelekomcloud_vpc_eip_v1" "fip" {
  count = var.lb_count

  bandwidth {
    charge_mode = "traffic"
    name        = "bw-${count.index + 1}"
    share_type  = "PER"
    size        = 100
  }

  publicip {
    type = "5_bgp"
  }
}

resource "opentelekomcloud_lb_loadbalancer_v3" "lb" {
  count = var.lb_count

  name             = "lb-${count.index + 1}"
  router_id        = var.vpc_id
  network_ids      = [var.subnet_id]
  subnet_id        = var.vpc_subnet
  l4_flavor        = data.opentelekomcloud_lb_flavor_v3.elb_dedicated_L4_flavor.id
  ip_target_enable = true

  public_ip {
    id = opentelekomcloud_vpc_eip_v1.fip[count.index].id
  }

  availability_zones = ["eu-de-01"]
}

resource "opentelekomcloud_lb_pool_v3" "pool" {
  count = var.lb_count
  name  = "kubernetes-nodeport-${count.index + 1}"
  #loadbalancer_id = opentelekomcloud_lb_loadbalancer_v3.lb[count.index].id
  listener_id  = opentelekomcloud_lb_listener_v3.listener[count.index].id
  lb_algorithm = "ROUND_ROBIN"
  protocol     = "TCP"
}

resource "opentelekomcloud_lb_listener_v3" "listener" {
  count           = var.lb_count
  protocol        = "TCP"
  protocol_port   = 80
  loadbalancer_id = opentelekomcloud_lb_loadbalancer_v3.lb[count.index].id

  tags = {
    muh = "kuh"
  }
}

resource "opentelekomcloud_lb_member_v3" "member" {
  count = length(var.lb_members) * var.lb_count

  pool_id       = opentelekomcloud_lb_pool_v3.pool[count.index % var.lb_count].id
  address       = var.lb_members[floor(count.index / var.lb_count)]
  protocol_port = 30281
}

