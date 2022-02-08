#######################################
# Top-level module variables (required)
#######################################

variable "ibmcloud_api_key" {
  type = string
  # TODO: Supported on tf 0.14
  # sensitive   = true
  description = "The IAM API key for authenticating with IBM Cloud APIs."
}

variable "ibmcloud_bootstrap_instance_type" {
  type        = string
  description = "Instance type for the bootstrap node. Example: `bx2-4x16`"
  default     = "bx2-4x16"
}

variable "ibmcloud_cis_crn" {
  type        = string
  description = "The CRN of CIS instance to use."
}

variable "ibmcloud_region" {
  type        = string
  description = "The target IBM Cloud region for the cluster."
}

variable "ibmcloud_master_instance_type" {
  type        = string
  description = "Instance type for the master node(s). Example: `bx2-4x16`"
  default     = "bx2-4x16"
}

# variable "ibmcloud_master_availability_zones" {
#   type        = list(string)
#   description = "The availability zones in which to create the masters. The length of this list must match master_count."
# }

# variable "ibmcloud_worker_availability_zones" {
#   type        = list(string)
#   description = "The availability zones to provision for workers. Worker instances are created by the machine-API operator, but this variable controls their supporting infrastructure (subnets, routing, dedicated hosts, etc.)."
# }

#######################################
# Top-level module variables (optional)
#######################################

variable "ibmcloud_master_dedicated_hosts" {
  type        = list(map(string))
  description = "(optional) The list of dedicated hosts in which to create the control plane nodes."
  default     = []
}

variable "ibmcloud_worker_dedicated_hosts" {
  type        = list(map(string))
  description = "(optional) The list of dedicated hosts in which to create the compute nodes."
  default     = []
}

variable "ibmcloud_extra_tags" {
  type        = list(string)
  description = <<EOF
(optional) Extra IBM Cloud tags to be applied to created resources.
Example: `[ "key:value", "foo:bar" ]`
EOF
  default     = []
}

variable "ibmcloud_publish_strategy" {
  type        = string
  description = "The cluster publishing strategy, either Internal or External"
  default     = "External"
  # TODO: Supported on tf 0.13
  # validation {
  #   condition     = "External" || "Internal"
  #   error_message = "The ibmcloud_publish_strategy value must be \"External\" or \"Internal\"."
  # }
}

variable "ibmcloud_resource_group_name" {
  type        = string
  description = <<EOF
(optional) The name of the resource group for the cluster. If this is set, the cluster is installed to that existing resource group
otherwise a new resource group will be created using cluster id.
EOF
  default     = ""
}

#######################################
# NC Modifications
#######################################

variable "openshift_cluster_name" {
  type        = string
  description = "The name of the OpenShift cluster"
}

variable "openshift_version" {
  type        = string
  description = "Version of OpenShift to install"
}

variable "openshift_base_domain" {
  type        = string
  description = "Base domain for the OpenShift cluster"
}

variable "openshift_pull_secret" {
  type        = string
  description = "Path to the pull secret for the OpenShift cluster.  Download from cloud.redhat.com."
}

variable "public_ssh_key" {
  type        = string
  description = "(optional) Path to the public SSH key for the OpenShift cluster."
  default     = ""
}

variable "airgap_config" {
  type        = map(string)
  description = "(optional) AirGap Configuration for the OpenShift cluster"
  default = {
    enabled    = false
    repository = ""
  }
}

variable "proxy_config" {
  type        = map(string)
  description = "(optional) Proxy Configuration for the OpenShift cluster"
  default = {
    enabled    = false
    httpProxy  = "http://user:password@ip:port"
    httpsProxy = "http://user:password@ip:port"
    noProxy    = "ip1,ip2,ip3,.example.com,cidr/mask"
  }
}

variable "openshift_cluster_network_cidr" {
  type        = string
  description = "(optional) OpenShift Cluster Network CIDR"
  default     = "10.128.0.0/14"
}

variable "openshift_service_network_cidr" {
  type        = string
  description = "(optional) OpenShift Service Network CIDR"
  default     = "172.30.0.0/16"
}

variable "openshift_cluster_network_host_prefix" {
  type        = number
  description = "(optional) OpenShift Cluster Network Host Prefix"
  default     = 23
}

variable "openshift_machine_cidr" {
  type        = list(string)
  description = "(optional) OpenShift Machine CIDR"
  default = [
    "10.0.0.0/16"
  ]
}

variable "openshift_master_count" {
  type        = string
  description = "(optional) OpenShift Master Node Count"
  default     = 3
}

variable "openshift_node_count" {
  type        = string
  description = "(optional) OpenShift Worker Node Count"
  default     = 3
}

variable "ibmcloud_worker_instance_type" {
  type        = string
  description = "(optional) OpenShift Worker Node Instance Type"
  default     = "bx2-4x16"
}

variable "openshift_trust_bundle" {
  type        = string
  description = "(optional) Path to OpenShift additional Trust Bundle"
  default     = ""
}

variable "network_resource_group_name" {
  type        = string
  description = "(optional) preexisting IBM Cloud resrouce group name for network resources"
  default     = ""
}

variable "destroy_bootstrap" {
  type        = bool
  description = "Destroy the bootstrap node"
  default     = false
}

variable "rhcos_image_url" {
  type        = string
  description = "(optional) URL of RHCOS image"
  default     = ""
}

# variable "user_name" {
#   type = string
# }

# variable "user_email" {
#   type = string
# }

# variable "git_org" {
#   type = string
# }

# variable "git_api_token" {
#   type = string
# }

# variable "ibm_entitlement_key" {
#   type = string
# }
