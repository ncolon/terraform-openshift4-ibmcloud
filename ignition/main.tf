locals {
  installer_workspace     = "${path.root}/installer/${var.cluster_name}"
  openshift_installer_url = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${var.openshift_version}"
  # openshift_installer_url = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/candidate-4.10"
}

resource "null_resource" "download_binaries" {
  triggers = {
    installer_workspace = local.installer_workspace
  }

  provisioner "local-exec" {
    when = create
    command = templatefile("${path.module}/scripts/download.sh.tmpl", {
      installer_workspace  = local.installer_workspace
      installer_url        = local.openshift_installer_url
      airgapped_enabled    = var.airgap_config["enabled"]
      airgapped_repository = var.airgap_config["repository"]
      pull_secret          = var.openshift_pull_secret
      openshift_version    = var.openshift_version
      path_root            = path.root
    })
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.triggers.installer_workspace}"
  }
}

resource "null_resource" "generate_manifests" {
  depends_on = [
    local_file.install_config_yaml
  ]

  triggers = {
    installer_workspace = local.installer_workspace
  }

  provisioner "local-exec" {
    when = create
    command = templatefile("${path.module}/scripts/manifests.sh.tmpl", {
      installer_workspace = self.triggers.installer_workspace
    })
    environment = {
      IC_API_KEY = var.ibmcloud_api_key
    }
  }
}

resource "null_resource" "generate_ignition" {
  depends_on = [
    local_file.manifests_cloud_provider_config_yaml,
    local_file.manifests_cluster_infrastructure_02_yaml,
    local_file.openshift_cluster_api_master_machines_yaml,
    local_file.openshift_cluster_api_worker_machineset_yaml,
    local_file.manifests-cloud-controller-manager-credentials,
    local_file.manifests-machine-api-credentials,
    local_file.manifests-ingress-operator-credentials,
    local_file.manifests-cluster-csi-drivers-credentials,
    local_file.manifests-image-registry-credentials
  ]

  triggers = {
    installer_workspace = local.installer_workspace
    cluster_id          = var.cluster_id
  }

  provisioner "local-exec" {
    when = create
    command = templatefile("${path.module}/scripts/ignition.sh.tmpl", {
      installer_workspace = self.triggers.installer_workspace
      cluster_id          = self.triggers.cluster_id
    })
    environment = {
      IC_API_KEY = var.ibmcloud_api_key
    }
  }
}


data "external" "ignition" {
  depends_on = [
    null_resource.generate_ignition
  ]

  program = ["bash", "${path.module}/scripts/ignition.sh"]
  query = {
    installer_workspace = local.installer_workspace
  }
}
