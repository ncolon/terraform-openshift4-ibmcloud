data "http" "images" {
  url = "https://raw.githubusercontent.com/openshift/installer/release-${local.major_version}/data/data/rhcos.json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  cluster_id       = "${var.openshift_cluster_name}-${random_string.cluster_id.result}"
  major_version    = length(regexall("-", var.openshift_version)) > 0 ? split("-", var.openshift_version)[1] : join(".", slice(split(".", var.openshift_version), 0, 2))
  rhcos_image_path = lookup(jsondecode(data.http.images.body), "baseURI")
  rhcos_image_file = lookup(lookup(lookup(jsondecode(data.http.images.body), "images"), "ibmcloud"), "path")
  rhcos_image      = join("", [local.rhcos_image_path, local.rhcos_image_file])
  public_ssh_key   = var.public_ssh_key == "" ? tls_private_key.installkey[0].public_key_openssh : file(var.public_ssh_key)
}

data "ibm_is_zones" "zones" {
  region = var.ibmcloud_region
}

# SSH Key for VMs
resource "tls_private_key" "installkey" {
  count     = var.public_ssh_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "write_private_key" {
  count           = var.public_ssh_key == "" ? 1 : 0
  content         = tls_private_key.installkey[0].private_key_pem
  filename        = "${path.root}/installer/${var.openshift_cluster_name}/openshift_rsa"
  file_permission = 0600
}

resource "local_file" "write_public_key" {
  content         = local.public_ssh_key
  filename        = "${path.root}/installer/${var.openshift_cluster_name}/openshift_rsa.pub"
  file_permission = 0600
}

data "ibm_iam_account_settings" "iam_account_settings" {
}
