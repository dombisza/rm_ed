## [CCE CLUSTER]

data "opentelekomcloud_cce_addon_template_v3" "autoscaler" {
  addon_version = var.autoscaler_version
  addon_name    = "autoscaler"
}

data "opentelekomcloud_cce_addon_template_v3" "metrics" {
  addon_version = var.metrics_version
  addon_name    = "metrics-server"
}

# data "opentelekomcloud_cce_addon_templates_v3" "everest" {
# cluster_version = var.everest_version
# addon_name      = "everest"
# }

resource "opentelekomcloud_cce_cluster_v3" "this" {
  name                   = "${var.prefix}-cluster"
  cluster_type           = "VirtualMachine"
  flavor_id              = "cce.s1.small"
  vpc_id                 = var.vpc_id
  subnet_id              = var.subnet_id
  container_network_type = var.cnt
  authentication_mode    = var.auth_type
  kube_proxy_mode        = var.proxy_mode
  eip                    = opentelekomcloud_vpc_eip_v1.this.publicip[0].ip_address
}

## [CCE NODEPOOLS]

resource "opentelekomcloud_cce_node_pool_v3" "this" {
  for_each                 = toset(var.azs)
  availability_zone        = each.key
  cluster_id               = opentelekomcloud_cce_cluster_v3.this.id
  name                     = "${var.prefix}-nodepool-v3-${each.key}"
  os                       = var.node_os
  flavor                   = var.node_flavor
  key_pair                 = var.key_name
  scale_enable             = var.scale_enabled
  initial_node_count       = var.scale_enabled ? var.scaling["start"] : null
  min_node_count           = var.scale_enabled ? var.scaling["min"] : null
  max_node_count           = var.scale_enabled ? var.scaling["max"] : null
  scale_down_cooldown_time = 100
  priority                 = 1
  runtime                  = "containerd"
  lifecycle {
    create_before_destroy = true
  }
  root_volume {
    size       = var.root_vol
    volumetype = "SSD"
  }
  data_volumes {
    size       = var.data_vol
    volumetype = "SSD"
  }
}


## [CCE SELF MANAGED NODES]
# dedicated nginx ingress nodes, not application nodes!

resource "opentelekomcloud_cce_node_v3" "node" {
  count             = var.ingress_node_count
  name              = "node${count.index + 1}"
  cluster_id        = opentelekomcloud_cce_cluster_v3.this.id
  availability_zone = var.availability_zone

  os        = var.node_os
  flavor_id = var.node_flavor
  key_pair  = var.key_name

  k8s_tags = {
    "ingress" = "true"
    #this is needed to avoid recreation of nodes on applies
    "node.cce.io/billing-mode" = "post-paid"
  }
  taints {
    key    = "ingress"
    value  = "true"
    effect = "NoSchedule"
  }
  root_volume {
    size       = var.root_vol
    volumetype = "SSD"
  }

  data_volumes {
    size       = var.data_vol
    volumetype = "SSD"
  }
}


## [CCE KUBECONFIG]

#resource "null_resource" "get_kube_config" {
#  depends_on = [opentelekomcloud_cce_cluster_v3.this]
#  provisioner "local-exec" {
#    command = "./get_kube_config.sh"
#  }
#}

resource "opentelekomcloud_vpc_eip_v1" "this" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.prefix}-kube-master"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "opentelekomcloud_cce_addon_v3" "metrics" {
  template_name    = data.opentelekomcloud_cce_addon_template_v3.metrics.addon_name
  template_version = data.opentelekomcloud_cce_addon_template_v3.metrics.addon_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.this.id

  values {
    basic = {
      swr_addr = data.opentelekomcloud_cce_addon_template_v3.metrics.swr_addr
      swr_user = data.opentelekomcloud_cce_addon_template_v3.metrics.swr_user
    }
    custom = {}
  }
}


#https://github.com/iits-consulting/terraform-opentelekomcloud-project-factory/blob/master/modules/cce/addons.tf
resource "opentelekomcloud_cce_addon_v3" "autoscaler" {
  template_name    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_name
  template_version = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.this.id

  values {
    basic = {
      swr_addr = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_addr
      swr_user = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_user
    }
    custom = {
      "cluster_id"                    = opentelekomcloud_cce_cluster_v3.this.id
      "tenant_id"                     = data.opentelekomcloud_identity_project_v3.current.id
      "coresTotal"                    = 16000
      "expander"                      = "priority"
      "logLevel"                      = 4
      "maxEmptyBulkDeleteFlag"        = 11
      "maxNodesTotal"                 = 6
      "memoryTotal"                   = 64000
      "scaleDownDelayAfterAdd"        = 15
      "scaleDownDelayAfterDelete"     = 15
      "scaleDownDelayAfterFailure"    = 3
      "scaleDownEnabled"              = true
      "scaleDownUnneededTime"         = 7
      "scaleUpUnscheduledPodEnabled"  = true
      "scaleUpUtilizationEnabled"     = true
      "unremovableNodeRecheckTimeout" = 7
    }
  }
}

output "node_private_ips" {
  value = [for node in opentelekomcloud_cce_node_v3.node : node.private_ip]
}
