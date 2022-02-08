data "template_file" "install_config_yaml" {
  template = <<EOF
apiVersion: v1
baseDomain: ${var.base_domain}
compute:
- hyperthreading: Enabled
  name: worker
  platform:
    ibmcloud:
      type: ${var.worker_vm_type}
  replicas: ${var.node_count}
controlPlane:
  hyperthreading: Enabled
  name: master
  platform:
    ibmcloud:
      type: ${var.master_vm_type}
  replicas: ${var.master_count}
metadata:
  creationTimestamp: null
  name: ${var.cluster_name}
networking:
  clusterNetwork:
  - cidr: ${var.cluster_network_cidr}
    hostPrefix: ${var.cluster_network_host_prefix}
  machineNetwork:
  - cidr: ${var.machine_cidr[0]}
  networkType: OpenShiftSDN
  serviceNetwork:
  - ${var.service_network_cidr}
platform:
  ibmcloud:
    region: ${var.ibmcloud_region}
    resourceGroupName: ${var.resource_group_name}
    # TODO: Removed from 4.10 in rc.1, revisit when added back
    # vpc: ${var.vpc_id}
    # vpcResourceGroupName: ${var.network_resource_group_name == "" ? var.resource_group_name : var.network_resource_group_name}
    # subnets:%{for subnet in var.worker_subnet_ids}
    #   - ${subnet}%{endfor}
    # TODO: add support for defaultMachinePlatform
    # defaultMachinePlatform:
    #   bootVolume:
    #   type:
    #   zones:
publish: ${var.publish_strategy}
pullSecret: '${chomp(file(var.openshift_pull_secret))}'
sshKey: '${chomp(var.public_ssh_key)}'
%{if var.airgap_config["enabled"]}imageContentSources:
- mirrors:
  - ${var.airgap_config["repository"]}
  source: quay.io/openshift-release-dev/ocp-release
- mirrors:
  - ${var.airgap_config["repository"]}
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev %{endif}
%{if var.proxy_config["enabled"]}proxy:
  httpProxy: ${var.proxy_config["httpProxy"]}
  httpsProxy: ${var.proxy_config["httpsProxy"]}
  noProxy: ${var.proxy_config["noProxy"]} %{endif}
%{if var.trust_bundle != ""}
${indent(2, "additionalTrustBundle: |\n${file(var.trust_bundle)}")} %{endif}
EOF
}

resource "local_file" "install_config_yaml" {
  content  = data.template_file.install_config_yaml.rendered
  filename = "${local.installer_workspace}/install-config.yaml"
  depends_on = [
    null_resource.download_binaries,
  ]
}

data "template_file" "manifests_cloud_provider_config_yaml" {
  template = <<EOF
apiVersion: v1
data:
  config: |+
    [global]
    version = 1.1.0
    [kubernetes]
    config-file = ""
    [provider]
    accountID = ${var.ibm_account_id}
    clusterID = ${var.cluster_id}
    cluster-default-provider = g2
    region = ${var.ibmcloud_region}
    g2Credentials = /etc/vpc/ibmcloud_api_key
    g2ResourceGroupName = ${var.resource_group_name}
    g2VpcName = ${var.vpc_name == "" ? "${var.cluster_id}-vpc" : var.vpc_name}
    g2workerServiceAccountID = ${var.ibm_account_id}
    g2VpcSubnetNames = ${join(",", distinct(concat(var.worker_subnet_names, var.master_subnet_names)))}


kind: ConfigMap
metadata:
  creationTimestamp: null
  name: cloud-provider-config
  namespace: openshift-config
EOF
}

resource "local_file" "manifests_cloud_provider_config_yaml" {
  depends_on = [
    null_resource.generate_manifests
  ]
  content  = data.template_file.manifests_cloud_provider_config_yaml.rendered
  filename = "${local.installer_workspace}/manifests/cloud-provider-config.yaml"
}

data "template_file" "manifests_cluster_infrastructure_02_yaml" {
  template = <<EOF
apiVersion: config.openshift.io/v1
kind: Infrastructure
metadata:
  creationTimestamp: null
  name: cluster
spec:
  cloudConfig:
    key: config
    name: cloud-provider-config
  platformSpec:
    type: IBMCloud
status:
  apiServerInternalURI: https://api-int.${var.cluster_name}.${var.base_domain}:6443
  apiServerURL: https://api.${var.cluster_name}.${var.base_domain}:6443
  controlPlaneTopology: HighlyAvailable
  etcdDiscoveryDomain: ""
  infrastructureName: ${var.cluster_id}
  infrastructureTopology: HighlyAvailable
  platform: IBMCloud
  platformStatus:
    ibmcloud:
      cisInstanceCRN: '${var.ibmcloud_cis_crn}'
      location: ${var.ibmcloud_region}
      resourceGroupName: ${var.resource_group_name}
    type: IBMCloud
EOF
}

resource "local_file" "manifests_cluster_infrastructure_02_yaml" {
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.manifests_cluster_infrastructure_02_yaml.rendered
  filename = "${local.installer_workspace}/manifests/cluster-infrastructure-02-config.yml"
}

data "template_file" "openshift_cluster_api_master_machines_yaml" {
  count    = var.master_count
  template = <<EOF
apiVersion: machine.openshift.io/v1beta1
kind: Machine
metadata:
  creationTimestamp: null
  labels:
    machine.openshift.io/cluster-api-cluster: ${var.cluster_id}
    machine.openshift.io/cluster-api-machine-role: master
    machine.openshift.io/cluster-api-machine-type: master
  name: ${var.cluster_id}-master-${count.index}
  namespace: openshift-machine-api
spec:
  lifecycleHooks: {}
  metadata: {}
  providerSpec:
    value:
      apiVersion: ibmcloudproviderconfig.openshift.io/v1beta1
      credentialsSecret:
        name: ibmcloud-credentials
      image: ${var.cluster_id}-rhcos
      kind: IBMCloudMachineProviderSpec
      metadata:
        creationTimestamp: null
      primaryNetworkInterface:
        securityGroups:
        - ${var.cluster_id}-sg-cluster-wide
        - ${var.cluster_id}-sg-openshift-net
        - ${var.cluster_id}-sg-control-plane
        - ${var.cluster_id}-sg-cp-internal
        subnet: ${var.master_subnet_names[count.index]}
      profile: ${var.master_vm_type}
      region: ${var.ibmcloud_region}
      resourceGroup: ${var.resource_group_name}
      userDataSecret:
        name: master-user-data
      vpc: ${var.vpc_name == "" ? "${var.cluster_id}-vpc" : var.vpc_name}
      zone: ${var.ibmcloud_region}-${count.index + 1}
status: {}
EOF
}

resource "local_file" "openshift_cluster_api_master_machines_yaml" {
  count = var.master_count
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.openshift_cluster_api_master_machines_yaml[count.index].rendered
  filename = "${local.installer_workspace}/openshift/99_openshift-cluster-api_master-machines-${count.index}.yaml"
}

locals {
  zone_node_replicas = [for idx in range(length(var.availability_zones)) : floor(var.node_count / length(var.availability_zones)) + (idx + 1 > (var.node_count % length(var.availability_zones)) ? 0 : 1)]
}

data "template_file" "openshift_cluster_api_worker_machineset_yaml" {
  count    = length(var.availability_zones)
  template = <<EOF
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  creationTimestamp: null
  labels:
    machine.openshift.io/cluster-api-cluster: ${var.cluster_id}
  name: ${var.cluster_id}-worker-${count.index + 1}
  namespace: openshift-machine-api
spec:
  replicas: ${local.zone_node_replicas[count.index]}
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: ${var.cluster_id}
      machine.openshift.io/cluster-api-machineset: ${var.cluster_id}-worker-${count.index + 1}
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: ${var.cluster_id}
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: ${var.cluster_id}-worker-${count.index + 1}
    spec:
      lifecycleHooks: {}
      metadata: {}
      providerSpec:
        value:
          apiVersion: ibmcloudproviderconfig.openshift.io/v1beta1
          credentialsSecret:
            name: ibmcloud-credentials
          image: ${var.cluster_id}-rhcos
          kind: IBMCloudMachineProviderSpec
          metadata:
            creationTimestamp: null
          primaryNetworkInterface:
            securityGroups:
            - ${var.cluster_id}-sg-cluster-wide
            - ${var.cluster_id}-sg-openshift-net
            subnet: ${var.worker_subnet_names[count.index]}
          profile: ${var.worker_vm_type}
          region: ${var.ibmcloud_region}
          resourceGroup: ${var.resource_group_name}
          userDataSecret:
            name: worker-user-data
          vpc: ${var.vpc_name == "" ? "${var.cluster_id}-vpc" : var.vpc_name}
          zone: ${var.ibmcloud_region}-${count.index + 1}
status:
  replicas: 0
EOF
}

resource "local_file" "openshift_cluster_api_worker_machineset_yaml" {
  count = length(var.availability_zones)
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.openshift_cluster_api_worker_machineset_yaml[count.index].rendered
  filename = "${local.installer_workspace}/openshift/99_openshift-cluster-api_worker-machineset-${count.index}.yaml"
}

data "template_file" "manifests-cloud-controller-manager-credentials" {
  template = <<EOF
apiVersion: v1
data:
  ibmcloud_api_key: ${base64encode(var.ibmcloud_api_key)}
kind: Secret
metadata:
  name: ibm-cloud-credentials
  namespace: openshift-cloud-controller-manager
type: Opaque
EOF
}

resource "local_file" "manifests-cloud-controller-manager-credentials" {
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.manifests-cloud-controller-manager-credentials.rendered
  filename = "${local.installer_workspace}/manifests/99_openshift-cloud-controller-manager-credentials.yaml"
}

data "template_file" "manifests-machine-api-credentials" {
  template = <<EOF
apiVersion: v1
data:
  ibmcloud_api_key: ${base64encode(var.ibmcloud_api_key)}
kind: Secret
metadata:
  name: ibmcloud-credentials
  namespace: openshift-machine-api
type: Opaque
EOF
}

resource "local_file" "manifests-machine-api-credentials" {
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.manifests-machine-api-credentials.rendered
  filename = "${local.installer_workspace}/manifests/99_openshift-machine-api-credentials.yaml"
}


data "template_file" "manifests-ingress-operator-credentials" {
  template = <<EOF
apiVersion: v1
data:
  ibmcloud_api_key: ${base64encode(var.ibmcloud_api_key)}
kind: Secret
metadata:
  name: cloud-credentials
  namespace: openshift-ingress-operator
type: Opaque
EOF
}

resource "local_file" "manifests-ingress-operator-credentials" {
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.manifests-ingress-operator-credentials.rendered
  filename = "${local.installer_workspace}/manifests/99_openshift-ingress-operator-credentials.yaml"
}

data "template_file" "sclient_toml" {
  template = <<EOF
[server]
debug_trace = false
[vpc]
iam_client_id = "bx"
iam_client_secret = "bx"
g2_token_exchange_endpoint_url = "https://iam.bluemix.net"
g2_riaas_endpoint_url = "https://${var.ibmcloud_region}.iaas.cloud.ibm.com"
g2_resource_group_id = "${var.resource_group_id}"
g2_api_key = "${var.ibmcloud_api_key}"
provider_type = "g2"
EOF
}

data "template_file" "manifests-cluster-csi-drivers-credentials" {
  template = <<EOF
apiVersion: v1
data:
  slclient.toml: ${base64encode(data.template_file.sclient_toml.rendered)}
kind: Secret
metadata:
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    app: ibm-vpc-block-csi-driver
    kubernetes.io/cluster-service: "true"
  name: storage-secret-store
  namespace: openshift-cluster-csi-drivers
type: Opaque
EOF
}

resource "local_file" "manifests-cluster-csi-drivers-credentials" {
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.manifests-cluster-csi-drivers-credentials.rendered
  filename = "${local.installer_workspace}/manifests/99_openshift-cluster-csi-drivers-credentials.yaml"
}

data "template_file" "manifests-image-registry-credentials" {
  template = <<EOF
apiVersion: v1
data:
  ibmcloud_api_key: ${base64encode(var.ibmcloud_api_key)}
kind: Secret
metadata:
  name: installer-cloud-credentials
  namespace: openshift-image-registry
type: Opaque
EOF
}

resource "local_file" "manifests-image-registry-credentials" {
  depends_on = [
    null_resource.generate_manifests,
  ]
  content  = data.template_file.manifests-image-registry-credentials.rendered
  filename = "${local.installer_workspace}/manifests/99_openshift-image-registry-credentials.yaml"
}
