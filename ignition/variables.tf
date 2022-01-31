variable "airgap_config" {
  type = map(string)
}

variable "base_domain" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_network_cidr" {
  type = string
}

variable "cluster_network_host_prefix" {
  type = string
}

variable "ibmcloud_region" {
  type = string
}

variable "machine_cidr" {
  type = list(string)
}

variable "master_count" {
  type = string
}

variable "master_vm_type" {
  type = string
}

variable "network_resource_group_name" {
  type = string
}

variable "node_count" {
  type = string
}

variable "openshift_pull_secret" {
  type = string
}

variable "publish_strategy" {
  type = string
}

variable "proxy_config" {
  type = map(string)
}

variable "public_ssh_key" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "service_network_cidr" {
  type = string
}

variable "trust_bundle" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "worker_vm_type" {
  type = string
}

variable "openshift_version" {
  type = string
}

variable "worker_subnet_ids" {
  type = list(string)
}

variable "cluster_id" {
  type = string
}

variable "ibm_account_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "ibmcloud_api_key" {
  type = string
}

variable "worker_subnet_names" {
  type = list(string)
}

variable "master_subnet_names" {
  type = list(string)
}

variable "ibmcloud_cis_crn" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = ""
}
