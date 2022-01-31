locals {
  prefix    = var.cluster_id
  zones_all = distinct(concat(var.zones_master, var.zones_worker))
}

############################################
# VPC
############################################

resource "ibm_is_vpc" "vpc" {
  name           = "${local.prefix}-vpc"
  resource_group = var.resource_group_id
  tags           = var.tags
}
#   address_prefix_management = "manual"
# }

# resource "ibm_is_vpc_address_prefix" "address_prefix" {
#   count = length(local.zones_all)
#   name  = "${local.prefix}-address-prefix-${count.index + 1}"
#   zone  = local.zones_all[count.index]
#   vpc   = ibm_is_vpc.vpc.id
#   cidr  = cidrsubnet(var.vpc_cidr, 2, count.index)
# }

############################################
# Public gateways
############################################

resource "ibm_is_public_gateway" "public_gateway" {
  count = length(local.zones_all)

  name           = "${local.prefix}-public-gateway-${local.zones_all[count.index]}"
  resource_group = var.resource_group_id
  tags           = var.tags
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.zones_all[count.index]
}

############################################
# Subnets
############################################

resource "ibm_is_subnet" "control_plane" {
  count = length(var.zones_master)

  name                     = "${local.prefix}-subnet-control-plane-${var.zones_master[count.index]}"
  resource_group           = var.resource_group_id
  tags                     = var.tags
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zones_master[count.index]
  public_gateway           = ibm_is_public_gateway.public_gateway[index(ibm_is_public_gateway.public_gateway.*.zone, var.zones_master[count.index])].id
  total_ipv4_address_count = "256"
  # ipv4_cidr_block = cidrsubnet(ibm_is_vpc_address_prefix.address_prefix[count.index].cidr, 6, 0)
}

resource "ibm_is_subnet" "compute" {
  count = length(var.zones_worker)

  name                     = "${local.prefix}-subnet-compute-${var.zones_worker[count.index]}"
  resource_group           = var.resource_group_id
  tags                     = var.tags
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zones_worker[count.index]
  public_gateway           = ibm_is_public_gateway.public_gateway[index(ibm_is_public_gateway.public_gateway.*.zone, var.zones_worker[count.index])].id
  total_ipv4_address_count = "256"
  # ipv4_cidr_block = cidrsubnet(ibm_is_vpc_address_prefix.address_prefix[count.index].cidr, 6, 1)
}
