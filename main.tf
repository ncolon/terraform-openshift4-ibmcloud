resource "random_string" "cluster_id" {
  length  = 5
  special = false
  upper   = false
}

module "network" {
  source                       = "./network"
  ibmcloud_region              = var.ibmcloud_region
  ibmcloud_resource_group_name = var.ibmcloud_resource_group_name
  ibmcloud_extra_tags          = var.ibmcloud_extra_tags
  cluster_id                   = local.cluster_id

  vpc_cidr = var.openshift_machine_cidr[0]

  ibmcloud_image_filepath            = local.rhcos_image
  ibmcloud_publish_strategy          = var.ibmcloud_publish_strategy
  ibmcloud_master_availability_zones = data.ibm_is_zones.zones.zones
  ibmcloud_worker_availability_zones = data.ibm_is_zones.zones.zones

  base_domain      = var.openshift_base_domain
  cluster_domain   = "${var.openshift_cluster_name}.${var.openshift_base_domain}"
  ibmcloud_cis_crn = var.ibmcloud_cis_crn
}

module "ignition" {
  source = "./ignition"
  depends_on = [
    module.network
  ]
  openshift_version           = var.openshift_version
  cluster_network_cidr        = var.openshift_cluster_network_cidr
  service_network_cidr        = var.openshift_service_network_cidr
  cluster_network_host_prefix = var.openshift_cluster_network_host_prefix
  cluster_name                = var.openshift_cluster_name
  cluster_id                  = local.cluster_id
  machine_cidr                = var.openshift_machine_cidr
  master_count                = var.openshift_master_count
  node_count                  = var.openshift_node_count
  master_vm_type              = var.ibmcloud_master_instance_type
  worker_vm_type              = var.ibmcloud_worker_instance_type
  base_domain                 = var.openshift_base_domain
  trust_bundle                = var.openshift_trust_bundle
  resource_group_name         = module.network.resource_group_name
  resource_group_id           = module.network.resource_group_id
  network_resource_group_name = var.network_resource_group_name
  vpc_id                      = module.network.vpc_id
  openshift_pull_secret       = var.openshift_pull_secret
  publish_strategy            = var.ibmcloud_publish_strategy
  proxy_config                = var.proxy_config
  public_ssh_key              = local.public_ssh_key
  ibmcloud_region             = var.ibmcloud_region
  airgap_config               = var.airgap_config
  worker_subnet_ids           = module.network.compute_subnet_id_list
  worker_subnet_names         = module.network.compute_subnet_name_list
  master_subnet_names         = module.network.control_plane_subnet_name_list
  ibm_account_id              = data.ibm_iam_account_settings.iam_account_settings.account_id
  availability_zones          = data.ibm_is_zones.zones.zones
  ibmcloud_api_key            = var.ibmcloud_api_key
  ibmcloud_cis_crn            = var.ibmcloud_cis_crn
  deploy_infra_nodes          = var.deploy_infra_nodes
  deploy_storage_nodes        = var.deploy_storage_nodes
  infra_vm_type               = var.infra_vm_type
  storage_vm_type             = var.storage_vm_type

}


module "bootstrap" {
  source = "./bootstrap"
  depends_on = [
    module.ignition,
    module.network
  ]
  resource_group_id                    = module.network.resource_group_id
  vpc_id                               = module.network.vpc_id
  control_plane_security_group_id_list = module.network.control_plane_security_group_id_list
  cos_resource_instance_crn            = module.network.cos_resource_instance_crn
  lb_kubernetes_api_public_id          = module.network.lb_kubernetes_api_public_id
  lb_kubernetes_api_private_id         = module.network.lb_kubernetes_api_private_id
  lb_pool_kubernetes_api_public_id     = module.network.lb_pool_kubernetes_api_public_id
  lb_pool_machine_config_id            = module.network.lb_pool_machine_config_id
  vsi_image_id                         = module.network.vsi_image_id
  control_plane_subnet_id_list         = module.network.control_plane_subnet_id_list
  control_plane_subnet_zone_list       = module.network.control_plane_subnet_zone_list
  lb_pool_kubernetes_api_private_id    = module.network.lb_pool_kubernetes_api_private_id
  ibmcloud_extra_tags                  = var.ibmcloud_extra_tags
  ibmcloud_region                      = var.ibmcloud_region
  cluster_id                           = local.cluster_id
  ignition_bootstrap_file              = module.ignition.bootstrap_file
  ibmcloud_publish_strategy            = var.ibmcloud_publish_strategy
  ibmcloud_bootstrap_instance_type     = var.ibmcloud_bootstrap_instance_type
  destroy_bootstrap                    = var.destroy_bootstrap
}


module "master" {
  source = "./master"
  depends_on = [
    module.ignition,
    module.bootstrap
  ]
  lb_kubernetes_api_private_id         = module.network.lb_kubernetes_api_private_id
  lb_pool_kubernetes_api_private_id    = module.network.lb_pool_kubernetes_api_private_id
  lb_pool_machine_config_id            = module.network.lb_pool_machine_config_id
  resource_group_id                    = module.network.resource_group_id
  vsi_image_id                         = module.network.vsi_image_id
  control_plane_subnet_id_list         = module.network.control_plane_subnet_id_list
  lb_kubernetes_api_public_id          = module.network.lb_kubernetes_api_public_id
  control_plane_subnet_zone_list       = module.network.control_plane_subnet_zone_list
  lb_pool_kubernetes_api_public_id     = module.network.lb_pool_kubernetes_api_public_id
  vpc_id                               = module.network.vpc_id
  control_plane_security_group_id_list = module.network.control_plane_security_group_id_list
  cluster_id                           = local.cluster_id
  ibmcloud_publish_strategy            = var.ibmcloud_publish_strategy
  ibmcloud_extra_tags                  = var.ibmcloud_extra_tags
  master_count                         = var.openshift_master_count
  ibmcloud_master_instance_type        = var.ibmcloud_master_instance_type
  ignition_master                      = module.ignition.master_ignition
}
