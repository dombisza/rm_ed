locals {
  wafd_count = var.wafd_config.wafd_count != null ? var.wafd_config.wafd_count : var.wafd_config.wafd_count
}

resource "opentelekomcloud_networking_secgroup_v2" "wafd_secgroup" {
  name = "waf"
  description = "Security group for WAFD service"
}

resource "opentelekomcloud_waf_dedicated_instance_v1" "wafd" {
  count = var.wafd_config.wafd_count

  name              = "${var.prefix}-wafd-instance-${count.index + 1}"
  availability_zone = "eu-de-01"
  specification     = "waf.instance.professional"
  flavor            = "s2.large.2"
  architecture      = "x86"
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id

  security_group = [opentelekomcloud_networking_secgroup_v2.wafd_secgroup.id]
}