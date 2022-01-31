locals {
  description      = "Created By OpenShift Installer"
  public_endpoints = var.ibmcloud_publish_strategy == "External" ? true : false
  tags = concat(
    ["kubernetes.io_cluster_${var.cluster_id}:owned"],
    var.ibmcloud_extra_tags
  )
}
