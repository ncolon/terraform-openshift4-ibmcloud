variable "ibmcloud_resource_group_name" {
  type = string
}

variable "ibmcloud_extra_tags" {
  type = list(string)
}

variable "ibmcloud_region" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "ibmcloud_publish_strategy" {
  type = string
}

variable "ibmcloud_image_filepath" {
  type = string
}

variable "ibmcloud_master_availability_zones" {
  type = list(string)
}

variable "ibmcloud_worker_availability_zones" {
  type = list(string)
}

variable "ibmcloud_cis_crn" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "cluster_domain" {
  type = string
}


variable "ibmcloud_master_dedicated_hosts" {
  type    = list(map(string))
  default = []
}

variable "ibmcloud_worker_dedicated_hosts" {
  type    = list(map(string))
  default = []
}

variable "vpc_cidr" {
  type = string
}
