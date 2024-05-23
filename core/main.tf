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
  source        = "./cluster"
  prefix        = local.prefix
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.subnet_id
  node_flavor   = "c4.xlarge.2"
  key_name      = module.key.key_name
  scale_enabled = true
  node_os       = "HCE OS 2.0"
  cnt           = "vpc-router"
}

module "elb" {
  source     = "./elb"
  prefix     = local.prefix
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_id
  lb_members = module.cce.node_private_ips
  vpc_subnet = module.vpc.vpc_subnet
}

output "elb_members" {
  value = module.cce.node_private_ips
}
