locals {
  prefix = "${var.owner}-${var.stage}"
  tags = {
    Stage      = var.stage
    Owner      = var.owner
    Managed_By = "terraform"
  }
}

module "key" {
  source = "./key"
  prefix = local.prefix
}

module "vpc" {
  source = "./vpc"
  prefix = local.prefix
  tags   = local.tags
}

module "natgw" {
  source     = "./natgw"
  prefix     = local.prefix
  vpc_id     = module.vpc.vpc_id
  network_id = module.vpc.network_id
  cidr       = module.vpc.cidr
}

module "bastion" {
  source     = "./bastion"
  prefix     = local.prefix
  tags       = local.tags
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_id
  network_id = module.vpc.network_id
  az         = "eu-de-01"
  key_name   = module.key.key_name
}

module "cce" {
  source             = "./cluster"
  prefix             = local.prefix
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.subnet_id
  node_flavor        = "c4.xlarge.2"
  key_name           = module.key.key_name
  scale_enabled      = true
  node_os            = "HCE OS 2.0"
  cnt                = "vpc-router"
  ingress_node_count = var.ingress_node_count
}

module "elb" {
  source     = "./elb"
  prefix     = local.prefix
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_id
  vpc_subnet = module.vpc.vpc_subnet
  # $repo_root/nginx/values.yaml
  ingress_nodeport = 31709
  #lb_config  = module.elb.lb_config
  lb_config = {
    lb_count      = var.lb_config.lb_count
    eip_bandwidth = var.lb_config.eip_bandwidth
    lb_algorithm  = var.lb_config.lb_algorithm

    lb_protocol = var.lb_config.lb_protocol
    lb_members  = module.cce.node_private_ips
  }
}
module "dns" {
  source     = "./dns"
  domain     = "sdombi.hu."
  sub_domain = "nginx"
  email      = "dombisza@gmail.com"
  elb_ip     = module.elb.lb_public_ips
}

output "elb_members" {
  value = module.cce.node_private_ips
  #value = [for node in opentelekomcloud_cce_node_v3.node : node.private_ip]
}

output "elb_instances" {
  value = module.elb.lb_public_ips
}
