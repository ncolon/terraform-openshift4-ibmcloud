#######################################
# Master module variables
#######################################

variable "control_plane_dedicated_host_id_list" {
  type    = list(string)
  default = []
}

variable "control_plane_security_group_id_list" {
  type = list(string)
}

variable "control_plane_subnet_id_list" {
  type = list(string)
}

variable "control_plane_subnet_zone_list" {
  type = list(string)
}

variable "cos_resource_instance_crn" {
  type    = string
  default = ""
}

variable "lb_kubernetes_api_public_id" {
  type = string
}

variable "lb_kubernetes_api_private_id" {
  type = string
}

variable "lb_pool_kubernetes_api_public_id" {
  type = string
}

variable "lb_pool_kubernetes_api_private_id" {
  type = string
}

variable "lb_pool_machine_config_id" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vsi_image_id" {
  type = string
}

#######################################
# NC Modifications
#######################################

variable "cluster_id" {
  type = string
}

variable "ibmcloud_publish_strategy" {
  type = string
}

variable "ibmcloud_extra_tags" {
  type = list(string)
}

variable "ignition_master" {
  type = string
}

variable "ibmcloud_master_instance_type" {
  type = string
}

variable "master_count" {
  type = number
}
